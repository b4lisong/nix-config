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
    nix develop                      # Enter dev environment manually
    direnv allow                     # Auto-enter dev environment
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
    # System-agnostic configuration
    systems = [ "x86_64-darwin" "aarch64-darwin" ];
    
    # Helper to create package sets for each system
    forAllSystems = nixpkgs.lib.genAttrs systems;
    
    # Get nixpkgs for a specific system
    nixpkgsFor = system: nixpkgs.legacyPackages.${system};

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
        macOS System Settings

        All configuration options are documented here:
        https://nix-darwin.github.io/nix-darwin/manual/index.html
      */
      
      /*
        Use TouchID for sudo
        note: the following command needs to be run for this to work when using DisplayLink
        /usr/bin/defaults write ~/Library/Preferences/com.apple.security.authorization.plist ignoreArd -bool TRUE
      */
      security.pam.services.sudo_local.touchIdAuth = true;

      system = {
        /* Version tracking for system updates */
        configurationRevision = self.rev or self.dirtyRev or null;

        /*
          Compatibility Version
          Don't change unless you're upgrading to a new nix-darwin release
        */
        stateVersion = 6;

        defaults = {
            # Show specific text as a greeting at login
            loginwindow.LoginwindowText = "おかえり、お兄ちゃん";

            menuExtraClock.Show24Hour = true; # show 24-hour clock

            # Customize dock
            dock = {
                autohide = true; # automatically hide and show the dock
                show-recents = false; # do not show recent apps in dock
                # do not automatically rearrange spaces based on most recent use.
                mru-spaces = false;
                expose-group-apps = true; # Group windows by application
                showhidden = true;
                autohide-delay = 0.0;              # Remove delay before showing dock
                autohide-time-modifier = 0.2;      # Speed up dock animation
                orientation = "bottom";             # Dock position: "bottom", "left", "right"
                tilesize = 48;                     # Icon size (16-128)
                magnification = true;              # Enable icon magnification on hover
                largesize = 64;                    # Magnified icon size
                minimize-to-application = true;     # Minimize windows into app icon
                persistent-apps = [                # Apps to keep in dock
                  "/Applications/Safari.app"
                  "/Applications/Cursor.app"
                ];
            };

            # Customize Finder
            finder = {
                _FXShowPosixPathInTitle = true; # show full path in finder title
                AppleShowAllExtensions = true; # show all file extensions
                FXEnableExtensionChangeWarning = false; # disable warning when changing file extension
                QuitMenuItem = true; # enable quit menu item
                ShowPathbar = true; # show path bar
                ShowStatusBar = true; # show status bar
                FXDefaultSearchScope = "SCcf";      # Search current folder by default
                FXPreferredViewStyle = "Nlsv";      # Default view: "icnv"=icon, "Nlsv"=list, "clmv"=column, "Flwv"=gallery
            };

            # Trackpad & Mouse
            trackpad = {
                Clicking = true; # enable tap-to-click
                TrackpadRightClick = true; # enable two-finger right click
                TrackpadThreeFingerDrag = true; # enable three-finger drag
            };
            # Mouse tracking speed
            ".GlobalPreferences"."com.apple.mouse.scaling" = 1.0;

            # Menubar and control center
            controlcenter = {
                Sound = true; # Keep sound options in menu bar
            };

            # Additional customization via NSGlobalDomain
            NSGlobalDomain = {
                AppleInterfaceStyle = "Dark"; # dark mode
                AppleKeyboardUIMode = 3; # Mode 3 enables full keyboard control.
                ApplePressAndHoldEnabled = true; # enable press and hold
                InitialKeyRepeat = 15; # Delay before key repeat starts (lower = faster)
                KeyRepeat = 2;                      # Key repeat rate (lower = faster)
                AppleShowAllExtensions = true;      # Show all file extensions
                AppleShowScrollBars = "Automatic";  # "WhenScrolling", "Automatic", "Always"
                NSNavPanelExpandedStateForSaveMode = true;  # Expand save panel by default
                NSNavPanelExpandedStateForSaveMode2 = true; # Expand save panel by default
                PMPrintingExpandedStateForPrint = true;     # Expand print panel by default
                PMPrintingExpandedStateForPrint2 = true;    # Expand print panel by default
                NSAutomaticCapitalizationEnabled = false; # disable auto capitalization
                NSAutomaticDashSubstitutionEnabled = false; # disable auto dash substitution
                NSAutomaticPeriodSubstitutionEnabled = false; # disable auto period substitution
                NSAutomaticQuoteSubstitutionEnabled = false; # disable auto quote substitution
                NSAutomaticSpellingCorrectionEnabled = false; # disable auto spelling correction
            };
        };
      };

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
      home = {
        /*
          Home Manager Version
          Should match the release branch you're using
        */
        stateVersion = "25.05";

        /*
          User Identity
          Home Manager uses this to know which user and directory to manage
        */
        username = "balisong";
        homeDirectory = "/Users/balisong";

        /*
          User Packages

          These packages are installed in the user's profile only.
          They won't be available to other users on the system.

          Categories:
          - CLI tools & system utilities
          - Editors
          - Development tools
        */
        packages = with pkgs; [
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
        ];
      };

      programs = {
        /*
          Shell Configuration
        
          Sets up Zsh with useful defaults:
          - Tab completion
          - Command suggestions based on history
          - Convenient aliases for common operations
        */
        zsh = {
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
        git = {
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
        vim = {
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
        starship = {
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
          Direnv Configuration
        
          Enable direnv for automatic environment management
        */
        direnv = {
          enable = true;
          enableZshIntegration = true;
          nix-direnv.enable = true;
        };

        /*
          Additional Program Configurations
        
          Uncomment and configure as needed:
          
          # Terminal multiplexer
          tmux = {
            enable = true;
            shortcut = "a";
            keyMode = "vi";
          };
        */

        /* Allow Home Manager to manage itself */
        home-manager = {
          enable = true;
        };
      };
    };

    /*
      Development Shell Factory Function
      Creates a development shell for any system (for working on this nix-config)
    */
    mkDevShell = system:
      let pkgs = nixpkgsFor system;
      in pkgs.mkShell {
        buildInputs = with pkgs; [
          # Nix development tools
          nixpkgs-fmt      # Format .nix files
          statix           # Linter for Nix
          deadnix          # Find unused Nix code
          nix-tree         # Visualize dependency trees
          manix            # Search Nix documentation
          nil              # Nix LSP
          
          # Helpful utilities for config work
          jq               # JSON processing (for flake.lock)
          git              # Version control
        ];
        
        shellHook = ''
          echo "🔧 Nix Configuration Development Environment"
          echo "Working on: $(basename $PWD)"
          echo "System: $(scutil --get LocalHostName) (${system})"
          echo ""
          echo "Available tools:"
          echo "  nixpkgs-fmt  - Format Nix files"
          echo "  statix       - Lint Nix files"
          echo "  deadnix      - Find dead code"
          echo "  manix        - Search Nix docs"
          echo ""
          echo "Useful commands:"
          echo "  sudo darwin-rebuild switch --flake ."
          echo "  sudo darwin-rebuild check --flake ."
          echo "  sudo darwin-rebuild --list-generations"
          echo "  nix flake update"
          echo ""
          
          # Set up convenient aliases (only in this dev shell)
          alias rebuild="darwin-rebuild switch --flake ."
          alias check="darwin-rebuild check --flake ."
          alias update="nix flake update"
          alias fmt="nixpkgs-fmt *.nix"
          alias lint="statix check ."
        '';
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
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            users.balisong = homeConfiguration;
          };
        }
      ];
    };

    /*
      Development Shells for All Systems
      This creates development environments for both Intel and Apple Silicon Macs
    */
    devShells = forAllSystems (system: {
      default = mkDevShell system;
    });
  };
}
