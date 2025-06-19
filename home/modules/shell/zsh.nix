{lib, ...}: let
  # Helper vars to make order values more readable
  # Used in initContent
  inherit (lib) mkOrder mkMerge; # inherit both mkOrder and mkMerge from lib
in {
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    syntaxHighlighting.enable = true;
    autosuggestion.enable = true;
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
        # zstyle ':completion:*:descriptions' format '%U%B%d%b%u'
        # zstyle ':completion:*:warnings' format '%BSorry, no matches for: %d%b'
      '')

      # Main config (1000, default)
      # General config, replaces initExtra
      (mkOrder 1000 ''
        # Your main zsh configuration
        # setopt GLOB_DOTS
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
  };
}
