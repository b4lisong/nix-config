configs/
├── system/
│   ├── services/
│   │   ├── skhd.nix           # System window manager
│   │   ├── aerospace.nix      # System tiling manager
│   │   └── yabai.nix          # Alternative tiling manager
│   ├── programs/
│   │   ├── zsh.nix            # System-wide zsh config
│   │   └── fonts.nix          # System font definitions
│   └── defaults/
│       ├── dock.nix           # macOS dock preferences
│       └── finder.nix         # macOS finder preferences
├── home/
│   ├── programs/
│   │   ├── starship.nix       # User prompt configuration
│   │   ├── git.nix            # User git config & aliases
│   │   ├── zsh.nix            # User shell aliases & functions
│   │   ├── vim.nix            # User editor configuration
│   │   └── tmux.nix           # User terminal multiplexer
│   ├── dotfiles/
│   │   ├── gitignore.nix      # Personal .gitignore templates
│   │   └── ssh-config.nix     # SSH client configuration
│   └── themes/
│       ├── catppuccin.nix     # User color schemes
│       └── terminal-themes.nix # Terminal color schemes
└── shared/
    ├── fonts/
    │   ├── nerd-fonts.nix     # Font definitions used by both
    │   └── programming-fonts.nix
    ├── themes/
    │   ├── base-colors.nix    # Color palettes used by both
    │   └── wallpapers.nix     # Shared wallpaper definitions
    └── templates/
        ├── devshells.nix      # Development environment templates
        └── project-templates.nix