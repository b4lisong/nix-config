/*
`home/profiles/base/default.nix`
Defines the user-level (Home Manager) packages and configurations
common to all systems.
*/
{pkgs, ...}: let
  vars = import ../../../variables;
in {
  imports = [
    ../../modules/editors/vim.nix # Traditional vim with shared configuration
    ../../modules/shell/zsh.nix
    ../../modules/shell/starship.nix
  ];

  home = {
    stateVersion = "25.05";
    inherit (vars.user) username;
    homeDirectory = "/Users/${vars.user.username}";
    packages = with pkgs; [
      # Version Control
      git # Distributed version control system
      lazygit # Terminal UI for git commands

      # System Utilities
      curl # Command line tool for transferring data
      tree # Display directory structure as tree
      htop # Interactive process viewer
      bat # Cat clone with syntax highlighting
      eza # Modern replacement for ls
      fd # Alternative to find command
      ripgrep # Fast grep alternative
      zoxide # Smarter cd command
      fzf # Fuzzy finder
      gdu # Disk usage analyzer with TUI
      duf # Disk usage/free utility, better 'df'
      delta # Syntax-highlighting pager for git,diff

      # Terminal Enhancement
      tmux # Terminal multiplexer
      starship # Customizable command prompt

      # Development Tools
      just # Command runner, like `make` but simpler
      sad # CLI search and replace, a better `sed`

      # File Transfer
      croc # Easy secure file transfer tool
    ];
  };

  programs = {
    # A command-line fuzzy finder
    fzf = {
      enable = true;
      # https://github.com/catppuccin/fzf
      # catppuccin-mocha
      colors = {
        "bg+" = "#313244";
        "bg" = "#1e1e2e";
        "spinner" = "#f5e0dc";
        "hl" = "#f38ba8";
        "fg" = "#cdd6f4";
        "header" = "#f38ba8";
        "info" = "#cba6f7";
        "pointer" = "#f5e0dc";
        "marker" = "#f5e0dc";
        "fg+" = "#cdd6f4";
        "prompt" = "#cba6f7";
        "hl+" = "#f38ba8";
      };
    };

    # zoxide is a smarter cd command, inspired by z and autojump.
    # It remembers which directories you use most frequently,
    # so you can "jump" to them in just a few keystrokes.
    # zoxide works on all major shells.
    #
    #   z foo              # cd into highest ranked directory matching foo
    #   z foo bar          # cd into highest ranked directory matching foo and bar
    #   z foo /            # cd into a subdirectory starting with foo
    #
    #   z ~/foo            # z also works like a regular cd command
    #   z foo/             # cd into relative path
    #   z ..               # cd one level up
    #   z -                # cd into previous directory
    #
    #   zi foo             # cd with interactive selection (using fzf)
    #
    #   z foo<SPACE><TAB>  # show interactive completions (zoxide v0.8.0+, bash 4.4+/fish/zsh only)
    zoxide = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
    };

    bat = {
      enable = true;
      config.pager = "less -FR";
    };

    eza = {
      enable = true;
      enableZshIntegration = true;
      icons = "auto";
      git = true;
      extraOptions = [
        "--group-directories-first"
        "--header"
      ];
    };

    git = {
      enable = true;
      inherit (vars.git) userName;
      inherit (vars.git) userEmail;
      extraConfig = {
        init.defaultBranch = vars.git.defaultBranch;
        pull.rebase = vars.git.pullRebase;
      };
    };

    direnv = {
      enable = true;
      enableZshIntegration = true;
      nix-direnv.enable = true;
    };

    home-manager.enable = true;
  };
}
