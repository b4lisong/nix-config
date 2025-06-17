/*
`home/profiles/base/default.nix`
Defines the user-level (Home Manager) packages and configurations
common to all systems.
*/
{ pkgs, ... }:
let vars = import ../../../variables;
in {
  imports = [ 
    ../../modules/editors/vim.nix
    ../../modules/shell/zsh.nix
    ../../modules/shell/starship.nix
  ];

  home = {
    stateVersion = "25.05";
    username = vars.user.username;
    homeDirectory = "/Users/${vars.user.username}";
    packages = with pkgs; [
      # Version Control
      git        # Distributed version control system
      lazygit    # Terminal UI for git commands

      # System Utilities
      curl       # Command line tool for transferring data
      tree       # Display directory structure as tree
      htop       # Interactive process viewer
      bat        # Cat clone with syntax highlighting
      eza        # Modern replacement for ls
      fd         # Alternative to find command
      ripgrep    # Fast grep alternative
      zoxide     # Smarter cd command
      fzf        # Fuzzy finder
      gdu        # Disk usage analyzer with TUI
      duf        # Disk usage/free utility, better 'df'
      delta      # Syntax-highlighting pager for git,diff

      # Terminal Enhancement
      tmux       # Terminal multiplexer
      starship   # Customizable command prompt

      # Development Tools
      just       # Command runner, like `make` but simpler
      sad        # CLI search and replace, a better `sed`

      # File Transfer
      croc       # Easy secure file transfer tool
    ];
  };

  programs = {

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
      userName = vars.git.userName;
      userEmail = vars.git.userEmail;
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
