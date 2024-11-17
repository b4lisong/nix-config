{
  config,
  pkgs-unstable,
  ...
}: let
  shellAliases = {
    # k = "kubectl"; # TODO: add kubectl
    lg = "lazygit";

    urldecode = "python3 -c 'import sys, urllib.parse as ul; print(ul.unquote_plus(sys.stdin.read()))'";
    urlencode = "python3 -c 'import sys, urllib.parse as ul; print(ul.quote_plus(sys.stdin.read()))'";
  };

  localBin = "${config.home.homeDirectory}/.local/bin";
  goBin = "${config.home.homeDirectory}/go/bin";
  rustBin = "${config.home.homeDirectory}/.cargo/bin";
in {
  # only works in bash/zsh, not nushell
  home.shellAliases = shellAliases;

  # TODO: add nushell support
  #programs.nushell = {
  #  enable = true;
  #  package = pkgs-unstable.nushell;
  #  configFile.source = ./config.nu;
  #  inherit shellAliases;
  #};

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    initExtraFirst = ''
      # Start the tmux session if not already in the tmux session
      if [[ ! -n $TMUX  ]]; then
        # Get the session IDs
        session_ids="$(tmux list-sessions)"

        # Create new session if no sessions exist
        if [[ -z "$session_ids" ]]; then
          tmux new-session
        fi

        # Select from following choices
        #   - Attach existing session
        #   - Create new session
        #   - Start without tmux
        create_new_session="Create new session"
        start_without_tmux="Start without tmux"
        choices="$session_ids\n''${create_new_session}:\n''${start_without_tmux}:"
        choice="$(echo $choices | fzf | cut -d: -f1)"

        if expr "$choice" : "[0-9]*$" >&/dev/null; then
          # Attach existing session
          tmux attach-session -t "$choice"
        elif [[ "$choice" = "''${create_new_session}" ]]; then
          # Create new session
          tmux new-session
        elif [[ "$choice" = "''${start_without_tmux}" ]]; then
          # Start without tmux
          :
        fi
      fi
    '';
  };

  programs.bash = {
    enable = true;
    enableCompletion = true;
    bashrcExtra = ''
      export PATH="$PATH:${localBin}:${goBin}:${rustBin}"
    '';
  };
}
