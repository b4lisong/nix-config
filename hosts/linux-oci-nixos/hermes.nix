# Hermes Agent gateway, run as the primary user.
#
# Secrets stay out of this public repo. ~/.config/hermes/secrets.env (mode
# 0600, created by hand) holds:
#   TELEGRAM_BOT_TOKEN      from @BotFather
#   TELEGRAM_ALLOWED_USERS  numeric Telegram user ID(s)
# The model login is not an env var: `hermes auth add openai-codex` stores it
# in ~/.hermes/auth.json, which activation never overwrites.
#
# The agent's standing instructions, ~/.hermes/SOUL.md, are deliberately
# unmanaged: they change often while tuning the agent, and describe this
# infrastructure in more detail than belongs in a public repo. The hard limits
# (approvals, deny rules) live in `settings` below and stay declarative.
{
  config,
  lib,
  hermes-agent,
  myvars,
  ...
}: let
  username = myvars.user.username;

  # The module hardens its units for an agent that should not escalate. This
  # one is meant to administer the host, so three settings are relaxed on both
  # units that run agents: the gateway (Telegram chats) and the backend, which
  # spawns the agent workers for dashboard chats.
  #   NoNewPrivileges  would make setuid sudo refuse to run.
  #   PrivateTmp       would hide tmux sockets in /tmp/tmux-<uid>, so the user
  #                    could not attach to sessions Hermes starts.
  #   PATH             the module limits it to hermes, bash, coreutils, and git;
  #                    this gives Hermes the same tools as a login shell,
  #                    including setuid sudo from /run/wrappers. A later
  #                    PATH= assignment overrides the module's in systemd.
  adminAgentService = {
    NoNewPrivileges = lib.mkForce false;
    PrivateTmp = lib.mkForce false;
    Environment = lib.mkAfter [
      "PATH=/run/wrappers/bin:/etc/profiles/per-user/${username}/bin:/run/current-system/sw/bin"
    ];
  };
in {
  imports = [hermes-agent.homeManagerModules.default];

  # The `hermes` CLI on the interactive PATH, sharing the service's state.
  programs.hermes-agent.enable = true;

  services.hermes-agent = {
    enable = true;
    gateway.enable = true;

    backend = {
      mode = "dashboard";
      host = "0.0.0.0";
      port = 9119;
    };

    environmentFiles = ["${config.home.homeDirectory}/.config/hermes/secrets.env"];

    settings = {
      dashboard = {
        # Trust only the reverse proxy (Caddy) for forwarded headers. Rootless
        # Docker containers reach the host from 10.0.0.163, not a bridge IP.
        trusted_proxies = ["10.0.0.163"];
      };

      # The admin ID stays in the untracked environment file; Nix emits the
      # literal placeholder for Hermes to resolve from the service environment.
      gateway.platforms.telegram.extra.allow_admin_from = ["\${HERMES_TELEGRAM_ADMIN_ID}"];

      # ChatGPT subscription through the Codex OAuth client.
      model = {
        provider = "openai-codex";
        default = "gpt-5.6-terra";
      };

      # The Codex CLI runs alongside Hermes with its own login. Both rotate
      # single-use refresh tokens, so borrowing ~/.codex/auth.json would let
      # either program log the other out.
      auth.adopt_external_logins = false;

      # Every flagged command waits for a yes/no in Telegram rather than an
      # auxiliary model's judgment, since this agent holds root on two hosts.
      # The deny globs block the coding agents' permission bypasses and force
      # pushes outright, including when typed into tmux via send-keys.
      approvals = {
        mode = "manual";
        deny = [
          "*dangerously-skip-permissions*"
          "*dangerously-bypass-approvals-and-sandbox*"
          "*codex*--yolo*"
          "*git push*--force*"
        ];
      };

      terminal.backend = "local";
    };
  };

  systemd.user.services.hermes-agent.Service = adminAgentService;
  systemd.user.services.hermes-backend.Service = adminAgentService;
}
