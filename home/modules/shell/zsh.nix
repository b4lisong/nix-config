{lib, ...}: let
  # Helper vars to make order values more readable
  # Used in initContent
  inherit (lib) mkOrder mkMerge; # inherit both mkOrder and mkMerge from lib
in {
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    autocd = true; # change dir just by typing its name
    shellAliases = {
      ls = "eza";
      ll = "eza -l";
      la = "eza -la";
      lt = "eza --tree";
      cat = "bat";
      ".." = "cd ..";
      "..." = "cd ../..";
      gs = "git status";
      ga = "git add";
      gc = "git commit";
      # zoxide aliases
      cd = "z"; # replace cd with z
      cdi = "zi"; # interactive selection
      cdr = "z -"; # go to previous directory
      cdf = "z -f"; # force directory change
      cdh = "z ~"; # go to home directory
    };
    # initContent gives us fine-grained control over
    #   extra settings and their relative ordering.
    # We can also apply conditional statements in these blocks
    initContent = mkMerge [
      # Very early (400)
      (mkOrder 400 ''
        # Performance timing (optional)
        # ZSH_START_TIME=$(($(date +%s%N)/1000000)
      '')

      # Early environment (500, mkBefore)
      # Replaces initExtraFirst
      (mkOrder 500 ''
        # Core environment setup
        # export LANG="en_US.UTF-8"
        # export LC_ALL="en_US.UTF-8"
      '')

      # Pre-completion (550)
      # Replaces initExtraBeforeCompInit
      (mkOrder 550 ''
        # Completion styling
        zstyle ':completion:*:*:*:*:*' menu select
        zstyle ':completion:*' auto-description 'specify: %d'
        zstyle ':completion:*' completer _expand _complete
        zstyle ':completion:*' format 'Completing %d'
        zstyle ':completion:*' group-name ""
        zstyle ':completion:*' list-colors ""
        zstyle ':completion:*' list-prompt %SAt %p: Hit TAB for more, or the character to insert%s
        zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
        zstyle ':completion:*' rehash true
        zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s
        zstyle ':completion:*' use-compctl false
        zstyle ':completion:*' verbose true
        zstyle ':completion:*:kill:*' command 'ps -u $USER -o pid,%cpu,tty,cputime,cmd'
      '')

      # Main config (1000, default)
      # General config, replaces initExtra
      (mkOrder 1000 ''
        # Your main zsh configuration
        setopt interactivecomments # allow comments in interactive mode
        setopt magicequalsubst     # enable filename expansion for arguments of the form 'anything=expression'
        setopt nonomatch           # hide error message if there is no match for the pattern
        setopt notify              # report the status of background jobs immediately
        setopt numericglobsort     # sort filenames numerically when it makes sense
        setopt promptsubst         # enable command substitution in prompt

        # Conditional claude code (via npm -g) alias
        [[ -f "$HOME/.npm-global/bin/claude" ]] && alias claude="$HOME/.npm-global/bin/claude"
      '')

      # Post-completion (1200)
      (mkOrder 1200 ''
        # Things that need to run after completion is set up
        # but before final initialization
      '')

      # Last-to-run config (1500, mkAfter)
      (mkOrder 1500 ''
        # Final setup, external tool integration
        # echo "Welcome to zsh!"
      '')
    ];

    # Syntax highlighting configuration using Home Manager options
    syntaxHighlighting = {
      enable = true;
      # Highlighters to enable
      highlighters = [
        "main"
        "brackets"
        "pattern"
      ];

      # Custom styles for syntax highlighting
      styles = {
        # Main highlighter styles
        default = "none";
        unknown-token = "underline";
        reserved-word = "fg=cyan,bold";
        suffix-alias = "fg=green,underline";
        global-alias = "fg=green,bold";
        precommand = "fg=green,underline";
        commandseparator = "fg=blue,bold";
        autodirectory = "fg=green,underline";
        path = "bold";
        path_pathseparator = "";
        path_prefix_pathseparator = "";
        globbing = "fg=blue,bold";
        history-expansion = "fg=blue,bold";
        command-substitution = "none";
        command-substitution-delimiter = "fg=magenta,bold";
        process-substitution = "none";
        process-substitution-delimiter = "fg=magenta,bold";
        single-hyphen-option = "fg=green";
        double-hyphen-option = "fg=green";
        back-quoted-argument = "none";
        back-quoted-argument-delimiter = "fg=blue,bold";
        single-quoted-argument = "fg=yellow";
        double-quoted-argument = "fg=yellow";
        dollar-quoted-argument = "fg=yellow";
        rc-quote = "fg=magenta";
        dollar-double-quoted-argument = "fg=magenta,bold";
        back-double-quoted-argument = "fg=magenta,bold";
        back-dollar-quoted-argument = "fg=magenta,bold";
        assign = "none";
        redirection = "fg=blue,bold";
        comment = "fg=black,bold";
        named-fd = "none";
        numeric-fd = "none";
        arg0 = "fg=cyan";

        # Bracket highlighter styles
        bracket-error = "fg=red,bold";
        bracket-level-1 = "fg=blue,bold";
        bracket-level-2 = "fg=green,bold";
        bracket-level-3 = "fg=magenta,bold";
        bracket-level-4 = "fg=yellow,bold";
        bracket-level-5 = "fg=cyan,bold";
        cursor-matchingbracket = "standout";
      };
    };
  };
}
