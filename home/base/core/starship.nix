{
  pkgs,
  # nur-ryan4yin,
  ...
}: {
  programs.starship = {
    enable = true;

    enableBashIntegration = true;
    enableZshIntegration = true;
    #enableNushellIntegration = true;

    settings =
      {
        # sources: 
        # https://gist.github.com/mIcHyAmRaNe/a6ee5ca3311d61ae6f181e691643925d
        # https://gist.github.com/pythoninthegrass/faff76c2f571c57126e793733aae167d
        add_newline = true;
        format = ''
          [┌╴\(](bold green)[$username@$hostname](bold blue)[\)](bold green)$os$container
          [| $all└─](bold green)$character
        '';
        character = {
          success_symbol = "[>](bold green)";
          error_symbol = "[](bold red)";
          # vicmd_symbol = "[V](bold green)";
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
          trim_at = ".";
          disabled = false;
        };
        container = {
          style = "bold red dimmed";
          format = "[\\[$symbol $name\\]]($style)";
        };
        os = {
          style = "bold white";
          format = "[\\[$symbol $arch$name\\]]($style)";
          disabled = false;
        };
        os.symbols = {
          Macos = "";
          NixOS = "";
          Kali = "";
          Linux = "";
          Windows = "";
          Unknown = "";
        };
        git_branch = {
          truncation_length = 16;
          truncation_symbol = "...";
          disabled = false;
        };
        git_status = {
          disabled = false;
        };
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
        #aws = {
        #  symbol = "🅰 ";
        #};
        #gcloud = {
        #  # do not show the account/project's info
        #  # to avoid the leak of sensitive information when sharing the terminal
        #  format = "on [$symbol$active(\($region\))]($style) ";
        #  symbol = "🅶 ️";
        #};

        #palette = "catppuccin_mocha";
      };
      #// builtins.fromTOML (builtins.readFile "${nur-ryan4yin.packages.${pkgs.system}.catppuccin-starship}/palettes/mocha.toml");
  };
}