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
      git lazygit curl tree htop bat ripgrep fd zoxide tmux starship
    ];
  };

  programs = {
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
