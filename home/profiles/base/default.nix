{ pkgs, ... }:
let vars = import ../../../variables;
in {
  imports = [ ../../modules/editors/vim.nix ];

  home = {
    stateVersion = "25.05";
    username = vars.user.username;
    homeDirectory = "/Users/${vars.user.username}";
    packages = with pkgs; [
      git lazygit curl tree htop bat ripgrep fd zoxide tmux starship
    ];
  };

  programs = {
    zsh = {
      enable = true;
      enableCompletion = true;
      autosuggestion.enable = true;
      shellAliases = {
        ll = "ls -l";
        la = "ls -la";
        ".." = "cd ..";
        "..." = "cd ../..";
        gs = "git status";
        ga = "git add";
        gc = "git commit";
      };
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

    starship = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
      settings = {
        add_newline = true;
        format = ''
          [┌╴\(](bold green)[$username$os$hostname](bold blue)[\)](bold green)$container $time
          [|](bold green) $all[└─](bold green) $character
        '';
        character = {
          success_symbol = "[❯](bold green)";
          error_symbol = "[✗](bold red)";
          vicmd_symbol = "[CMD❮](bold yellow)";
        };
        username = {
          style_user = "blue bold";
          style_root = "red bold";
          format = "[$user]($style)";
          disabled = false;
          show_always = true;
        };
        hostname = {
          ssh_only = false;
          format = "[$ssh_symbol](bold blue)[$hostname](bold blue)";
          trim_at = ".companyname.com";
          disabled = false;
        };
        os = {
          style = "bold white";
          format = "@[$symbol$arch](style) ";
          disabled = false;
        };
        os.symbols = {
          Macos = "";
          NixOS = "";
          Kali = "";
          Linux = "";
          Windows = "";
          Unknown = "";
        };
        git_branch = {
          truncation_length = 16;
          truncation_symbol = "...";
          disabled = false;
        };
        git_status.disabled = false;
        git_commit = {
          commit_hash_length = 4;
          tag_disabled = false;
          only_detached = false;
        };
        directory = {
          truncation_length = 8;
          truncation_symbol = "…/";
          truncate_to_repo = true;
          read_only = "🔒";
        };
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
