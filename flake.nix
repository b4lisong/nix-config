/*
  Nix Darwin Configuration with Home Manager
  
  This flake configures:
  - System-level packages and settings via nix-darwin
  - User-level packages and dotfiles via Home Manager
  - Development environment setup

  Current state:
  - Single flake.nix
  - Single-machine configuration (macOS/Darwin x86_64)

  TODO:
  - [ ] Re-factor into:
    - [ ] Multi-machine/host, multi-OS, multi-arch support
    - [ ] Inheritable hierarchy with base config (for all machines)
      - [ ] Darwin (base)
        - [ ] Machine 1,2,etc.
      - [ ] Linux (base)
        - [ ] Machine 4,5,etc.

  
  Usage:
    darwin-rebuild switch --flake .
*/
{
  description = "Example nix-darwin system flake with Home Manager";

  /*
    Input Dependencies
    
    We pin specific versions to ensure reproducibility:
    - nixpkgs: Main package repository (Darwin-optimized branch)
    - nix-darwin: macOS system configuration management
    - home-manager: User-specific package and dotfile management
  */
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-25.05-darwin";
    nix-darwin.url = "github:nix-darwin/nix-darwin/nix-darwin-25.05";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager/release-25.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs, home-manager }:
  let
    /*
      System-Level Configuration Function
      
      This defines macOS system settings and packages that are available
      to all users on the system. Think of this as "sudo" level configuration.
    */
    configuration = { pkgs, ... }: {
      /*
        System Packages
        These are installed globally and available to all users
      */
      environment.systemPackages = [
        pkgs.vim
      ];

      /* Enable flakes and the new nix command interface */
      nix.settings.experimental-features = "nix-command flakes";

      /*
        Alternative Shells
        Uncomment to enable system-wide shell support
      */
      # programs.fish.enable = true;

      /*
        System Fonts
        This enables system-wide font support
      */
      fonts.packages = with pkgs; [
        # Nerd Fonts
        nerd-fonts.sauce-code-pro
        nerd-fonts.symbols-only
        # Icon Fonts
        font-awesome
        material-design-icons
        # Emoji Fonts
        noto-fonts-emoji
        # Other Fonts
        dejavu_fonts
      ];

      /*
        Homebrew Integration
        
        This enables Homebrew management through nix-darwin.
        Use this for GUI applications that need Spotlight integration.
      */
      homebrew = {
        enable = true;
        onActivation.cleanup = "zap"; # Remove all undefined packages
        
        # Install GUI applications via Homebrew casks
        casks = [
          #"visual-studio-code"
          #"discord"
          #"spotify"
          #"google-chrome"
          #"1password"
          "cursor"
          "scroll-reverser"
          "little-snitch"
        ];
        
        # Regular Homebrew packages (if needed)
        brews = [
          # "some-package-not-in-nix"
        ];
        
        # Mac App Store apps
        masApps = {
          # "App Name" = app-id;
          # "Xcode" = 497799835;
        };
      };

      /* Version tracking for system updates */
      system.configurationRevision = self.rev or self.dirtyRev or null;

      /*
        Compatibility Version
        Don't change unless you're upgrading to a new nix-darwin release
      */
      system.stateVersion = 6;

      /*
        Target Platform
        Use "aarch64-darwin" for Apple Silicon Macs
        Use "x86_64-darwin" for Intel Macs
      */
      nixpkgs.hostPlatform = "x86_64-darwin";

      /*
        Nixpkgs Configuration
        
        allowUnfree: Permits installation of unfree/proprietary software
      */
      nixpkgs.config.allowUnfree = true;

      /*
        Primary User Configuration
        
        This sets the primary user for nix-darwin operations.
        Required for Homebrew and other user-specific features.
      */
      system.primaryUser = "balisong";

      /*
        User Account Setup
        Required for Home Manager integration
      */
      users.users.balisong = {
        name = "balisong";
        home = "/Users/balisong";
      };
    };

    /*
      User-Level Configuration Function
      
      This defines user-specific packages, dotfiles, and program configurations.
      These settings only affect the specified user, not the entire system.
    */
    homeConfiguration = { pkgs, ... }: {
      /*
        User Identity
        Home Manager uses this to know which user and directory to manage
      */
      home.username = "balisong";
      home.homeDirectory = "/Users/balisong";

      /*
        User Packages
        
        These packages are installed in the user's profile only.
        They won't be available to other users on the system.
        
        Categories:
        - CLI tools & system utilities
        - Editors
        - Development tools
      */
      home.packages = with pkgs; [
        # CLI tools & utilities
        git
        lazygit
        curl
        tree
        htop
        bat
        ripgrep
        fd
        zoxide
        tmux
        starship

        # Editors
        
        /* Development Tools */
        # Nix
        nil
        /*
          Development Tools (commented out - uncomment as needed)
          
          # JavaScript/Node.js
          nodejs
          yarn
          
          # Python
          python3
          python3Packages.pip
          
          # Rust
          rustc
          cargo
          
          # Go
          go
        */
      ];

      /*
        Shell Configuration
        
        Sets up Zsh with useful defaults:
        - Tab completion
        - Command suggestions based on history
        - Convenient aliases for common operations
      */
      programs.zsh = {
        enable = true;
        enableCompletion = true;
        autosuggestion.enable = true;
        shellAliases = {
          # Navigation shortcuts
          ll = "ls -l";
          la = "ls -la";
          ".." = "cd ..";
          "..." = "cd ../..";
          
          # Git shortcuts
          gs = "git status";
          ga = "git add";
          gc = "git commit";
        };
      };

      /*
        Git Configuration
        
        Declaratively manages your global Git settings.
      */
      programs.git = {
        enable = true;
        userName = "b4lisong";
        userEmail = "5397809+b4lisong@users.noreply.github.com";
        extraConfig = {
          init.defaultBranch = "main";
          pull.rebase = true;
          # push.autoSetupRemote = true;
        };
      };

      /*
        Vim Configuration
        
        This replaces your .vimrc file with declarative Home Manager configuration.
        All your vim settings are now managed by Nix.
      */
      programs.vim = {
        enable = true;
        
        /*
          Vim Settings
          These correspond to the 'set' commands in your .vimrc
        */
        settings = {
          # Use spaces instead of tabs
          expandtab = true;
          
          # Number of spaces per indentation level
          tabstop = 4;
          
          # Number of spaces for automatic indentation
          shiftwidth = 4;
          
          # Show line numbers
          number = true;
        };
        
        /*
          Extra Vim Configuration
          For settings that don't have direct Home Manager options,
          we use extraConfig to include raw vim script
        */
        extraConfig = ''
          " Number of spaces inserted when pressing Tab
          set softtabstop=4

          " Enable automatic indentation
          set autoindent
          
          " Enable syntax highlighting
          syntax on
          
          " Enable filetype detection, load any filetype-specific plugins, indentation, etc.
          filetype plugin indent on
          
          " Highlight the current line
          set cursorline

          " Enable incremental search
          set incsearch
          
          " Enable highlighting all the matches in incsearch mode
          " But don't enable hlsearch always
          augroup vimrc-incsearch-highlight
            autocmd!
            autocmd CmdlineEnter [/\?] :set hlsearch
            autocmd CmdlineLeave [/\?] :set nohlsearch
          augroup END

          " Custom key bindings for faster vertical movement
          " J moves down 5 lines, K moves up 5 lines
          nnoremap J 5j
          nnoremap K 5k
          
          " Set colorscheme (will be available after we create the color file)
          " colorscheme catppuccin_mocha
        '';
      };

      /*
      Modern shell prompt
      */
      programs.starship = {
        enable = true;
        enableBashIntegration = true;
        enableZshIntegration = true;

        settings = {
          # kali linux prompt copy (w/modifications)
          # Inspo:
          #   https://gist.githubusercontent.com/mIcHyAmRaNe/a6ee5ca3311d61ae6f181e691643925d/raw/cc26b710fce3c21fe15edf6623be5cd12e4d5a32/starship.toml

          # Inserts a blank line between shell prompts
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

          # No need for env variables as starship provides a way to show your current distro
          os = {
            style = "bold white";
            format = "@[$symbol$arch](style) ";
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
        };
      };

      /*
        Additional Program Configurations
        
        Uncomment and configure as needed:
        
        # Terminal multiplexer
        programs.tmux = {
          enable = true;
          shortcut = "a";
          keyMode = "vi";
        };
        
        # Directory-based development environments
        programs.direnv = {
          enable = true;
          enableZshIntegration = true;
          nix-direnv.enable = true;
        };
      */

      /* Allow Home Manager to manage itself */
      programs.home-manager.enable = true;

      /*
        Home Manager Version
        Should match the release branch you're using
      */
      home.stateVersion = "25.05";
    };
  in
  {
    /*
      Darwin System Configuration Output
      
      This combines nix-darwin with Home Manager to create a complete
      system configuration. The name "a2251" should match your hostname.
      
      Find your hostname with: scutil --get LocalHostName
    */
    darwinConfigurations."a2251" = nix-darwin.lib.darwinSystem {
      modules = [ 
        /* System-level configuration */
        configuration 
        
        /* Home Manager integration */
        home-manager.darwinModules.home-manager
        {
          /*
            Home Manager Settings
            
            useGlobalPkgs: Allow Home Manager to use system packages
            useUserPackages: Install packages in user profile properly
          */
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.balisong = homeConfiguration;
        }
      ];
    };
  };
}
