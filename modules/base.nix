{
  pkgs,
  myvars,
  #nuenv, # TODO: add nuenv
  nixpkgs,
  lib,
  ...
} @ args: {
  nixpkgs.overlays =
    [
      # nuenv.overlays.default #TODO: add nuenv
    ]
    ++ (import ../overlays args);

  # auto upgrade nix to the unstable version
  nix.package = pkgs.nixVersions.latest;

  environment.systemPackages = with pkgs; [
    # development & system management
    bash-completion
    bat # A cat(1) clone with wings.
    coreutils # GNU core utilities

    # system monitoring
    btop # A monitor of system resources # TODO: define in home/base/core/btop.nix
    iftop # A network bandwidth monitoring tool
    htop # An interactive process viewer

    # version control
    git # used by nix flakes
    git-lfs # used by huggingface models

    # archives
    unrar
    zip
    xz
    zstd
    unzipNLS
    p7zip
    cabextract

    # Text Processing
    # Docs: https://github.com/learnbyexample/Command-line-text-processing
    gnugrep # GNU grep, provides `grep`/`egrep`/`fgrep`
    gnused # GNU sed, very powerful(mainly for replacing text in files)
    gawk # GNU awk, a pattern scanning and processing language
    jq # A lightweight and flexible command-line JSON processor
    ripgrep # ripgrep recursively searches directories for a regex pattern

    # networking tools
    mtr # A network diagnostic tool
    iperf3
    dnsutils # `dig` + `nslookup`
    ldns # replacement of `dig`, it provide the command `drill`
    wget
    curl
    aria2 # A lightweight multi-protocol & multi-source command-line download utility
    socat # replacement of openbsd-netcat
    nmap # A utility for network discovery and security auditing
    ipcalc # it is a calculator for the IPv4/v6 addresses

    # misc
    file
    findutils
    which
    tree
    gnutar
    rsync
    neofetch
  ];

  users.users.${myvars.username} = {
    description = myvars.userfullname;
    openssh.authorizedKeys.keys = myvars.sshAuthorizedKeys;
  };

  nix.settings = {
    # enable flakes globally
    experimental-features = ["nix-command" "flakes"];

    trusted-users = [myvars.username];
  };

  # make `nix run nixpkgs#nixpkgs` use the same nixpkgs as the one used by this flake.
  nix.registry.nixpkgs.flake = nixpkgs;

  environment.etc."nix/inputs/nixpkgs".source = "${nixpkgs}";
  # make `nix repl '<nixpkgs>'` use the same nixpkgs as the one used by this flake.
  # discard all the default paths, and only use the one from this flake.
  nix.nixPath = lib.mkForce ["/etc/nix/inputs"];
  # https://github.com/NixOS/nix/issues/9574
  nix.settings.nix-path = lib.mkForce "nixpkgs=/etc/nix/inputs/nixpkgs";
}