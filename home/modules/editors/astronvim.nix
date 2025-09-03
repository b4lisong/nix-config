# AstroNvim Configuration with Nix Integration
# Pure AstroNvim setup using the official template
{
  config,
  lib,
  pkgs,
  ...
}: {
  programs.neovim = {
    enable = true;
    
    # Use stable neovim package
    package = pkgs.neovim-unwrapped;
    
    # Don't override system editor initially
    defaultEditor = false;
    vimAlias = false;
    viAlias = false;

    # System-level tools and language servers
    # AstroNvim will use these system-installed tools
    extraPackages = with pkgs; [
      # Language servers for AstroNvim LSP integration
      nixd # Nix language server
      nodePackages.typescript-language-server # TypeScript/JavaScript LSP
      lua-language-server # Lua LSP
      python3Packages.python-lsp-server # Python LSP
      vscode-langservers-extracted # JSON, HTML, CSS, ESLint language servers
      gopls # Go language server

      # Development tools that AstroNvim plugins will use
      ripgrep # Used by telescope for live grep
      fd # Used by telescope for file finding
      tree-sitter # Required for treesitter grammars
      
      # Go toolchain and tools
      go
      gotools
      golangci-lint
      
      # Git (usually already available, but ensuring it's present)
      git
    ];
  };

  # Install AstroNvim using the official template
  xdg.configFile."nvim" = {
    source = pkgs.fetchFromGitHub {
      owner = "AstroNvim";
      repo = "template";
      rev = "v4.7.7"; # Latest stable release
      sha256 = "sha256-bOGRP7FoVeOE8qXWbhL3aGexOP7Cvo70WN8v2R8j8kQ=";
    };
    recursive = true;
  };

  # Shell aliases
  programs.zsh.shellAliases = lib.mkIf config.programs.zsh.enable {
    v = "vim";    # Keep traditional vim alias
    nv = "nvim";  # AstroNvim alias
  };
}