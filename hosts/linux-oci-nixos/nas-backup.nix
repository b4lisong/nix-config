# Daily rsync of /home and /srv to the NAS over Tailscale.
#
# The NAS keeps history through ZFS snapshots of the receiving dataset, so
# this side only maintains a mirror. The NAS is addressed by its MagicDNS name
# so no tailnet addresses end up in this public repository.
#
# Application data is copied consistently without stopping anything: each
# running compose project is paused (cgroup freezer) while its bind mounts are
# copied, which leaves the files exactly as a power cut would. Databases
# recover from that state on startup, so no per-database dump logic is
# needed. Projects and their data directories are discovered from Docker at
# run time; adding an app requires no change here as long as it bind-mounts
# its data under /home or /srv. Named volumes are not covered because the
# Docker data root is excluded.
{
  lib,
  pkgs,
  myvars,
  ...
}: let
  inherit (myvars.user) username;

  remote = "${username}@${myvars.hosts.nas.hostname}";
  remoteDir = "/mnt/backup/systems/server/oci-nixos";
  # The user's existing key is already authorized on the NAS. Reusing it adds
  # no exposure: anyone who can read it here can already reach every host
  # that authorizes it.
  sshKey = "/home/${username}/.ssh/id_ed25519";

  # Regenerable or disposable data. Anchored paths are relative to / because
  # rsync runs with --relative.
  excludes = pkgs.writeText "nas-backup-excludes" ''
    /home/*/.cache/
    /home/*/.local/share/docker/
    /srv/.pnpm-store/
    /srv/lost+found/
    node_modules/
    .direnv/
  '';

  backupScript = pkgs.writeShellApplication {
    name = "nas-backup";
    runtimeInputs = [
      pkgs.coreutils
      pkgs.docker
      pkgs.gawk
      pkgs.gnused
      pkgs.openssh
      pkgs.rsync
    ];
    text = ''
      # The receiving user is not root on the NAS, so --fake-super stores
      # ownership (including rootless Docker subuids), modes, ACLs and
      # xattrs in user.rsync.* xattrs on the ZFS side.
      rsync_opts=(
        --archive --hard-links --acls --xattrs
        --numeric-ids --delete --relative
        --rsync-path="rsync --fake-super"
        --rsh="ssh -i ${sshKey} -o BatchMode=yes -o ConnectTimeout=30 -o StrictHostKeyChecking=accept-new -o UserKnownHostsFile=$STATE_DIRECTORY/known_hosts"
      )

      run_rsync() {
        local rc=0
        rsync "''${rsync_opts[@]}" "$@" "${remote}:${remoteDir}/" || rc=$?
        # 24: files vanished mid-transfer, expected when copying a live system.
        if ((rc == 24)); then
          echo "some source files vanished during transfer"
          rc=0
        fi
        return "$rc"
      }

      status=0
      app_paths="$RUNTIME_DIRECTORY/app-paths"
      : >"$app_paths"

      paused=()
      unpause_paused() {
        if ((''${#paused[@]})); then
          docker unpause "''${paused[@]}" >/dev/null || {
            echo "failed to unpause: ''${paused[*]}" >&2
            status=1
          }
          paused=()
        fi
      }
      trap unpause_paused EXIT

      DOCKER_HOST="unix:///run/user/$(id -u ${username})/docker.sock"
      export DOCKER_HOST

      declare -A projects=()
      if [[ -S ''${DOCKER_HOST#unix://} ]]; then
        listing=$(docker ps --format '{{.ID}} {{.Label "com.docker.compose.project"}}')
        while read -r id project; do
          [[ -n $id ]] || continue
          # Containers outside compose are handled one by one.
          projects[''${project:-$id}]+="$id "
        done <<<"$listing"
      else
        echo "rootless Docker is not running; copying without pausing"
      fi

      for project in "''${!projects[@]}"; do
        read -ra ids <<<"''${projects[$project]}"
        sources=$(docker inspect --format '{{range .Mounts}}{{if eq .Type "bind"}}{{println .Source}}{{end}}{{end}}' "''${ids[@]}")
        mapfile -t mounts < <(printf '%s\n' "$sources" | awk '/^\/(home|srv)(\/|$)/' | sort -u)
        if ((''${#mounts[@]} == 0)); then
          echo "$project: no bind mounts under /home or /srv"
          continue
        fi

        echo "$project: pausing ''${#ids[@]} container(s) to copy ''${mounts[*]}"
        # Recorded before pausing so a partial failure still gets unpaused.
        paused=("''${ids[@]}")
        if ! docker pause "''${ids[@]}" >/dev/null; then
          echo "$project: pause failed; copying while running" >&2
          status=1
        fi
        run_rsync "''${mounts[@]}" || {
          echo "$project: rsync failed" >&2
          status=1
        }
        unpause_paused

        # Escape rsync pattern metacharacters so paths match literally.
        printf '%s\n' "''${mounts[@]}" | sed 's/[][*?\\]/\\&/g' >>"$app_paths"
      done

      # Everything else. The paths copied above are excluded, which also
      # protects them from --delete, so their consistent copies are kept.
      run_rsync --exclude-from="$app_paths" --exclude-from=${excludes} /home /srv || {
        echo "rsync of /home and /srv failed" >&2
        status=1
      }

      exit "$status"
    '';
  };
in {
  systemd.services.nas-backup = {
    description = "Back up /home and /srv to the NAS";
    wants = ["network-online.target"];
    after = ["network-online.target" "tailscaled.service"];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = lib.getExe backupScript;
      StateDirectory = "nas-backup";
      RuntimeDirectory = "nas-backup";
      Nice = 19;
      IOSchedulingClass = "idle";
    };
  };

  # Well clear of the nightly auto-upgrade, which starts at midnight with up
  # to 45 minutes of delay.
  systemd.timers.nas-backup = {
    wantedBy = ["timers.target"];
    timerConfig = {
      OnCalendar = "*-*-* 03:00:00";
      RandomizedDelaySec = "30min";
      Persistent = true;
    };
  };
}
