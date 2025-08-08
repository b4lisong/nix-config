# Neovim Configuration Documentation

A modern, performance-focused Neovim configuration built with Nix, Home Manager, and lazy.nvim for a complete IDE experience.

## Table of Contents

- [Overview](#overview)
- [Architecture](#architecture)
- [Quick Start](#quick-start)
- [Plugin Documentation](#plugin-documentation)
- [Keymap Reference](#keymap-reference)
- [Language Support](#language-support)
- [Customization Guide](#customization-guide)
- [Troubleshooting](#troubleshooting)

## Overview

This Neovim configuration provides a complete IDE experience while maintaining the performance and simplicity that makes Neovim great. It combines the power of Nix package management with modern plugin architecture for a reproducible, maintainable development environment.

### Key Features

- **Modern Plugin Management**: lazy.nvim for fast, asynchronous plugin loading
- **Complete Language Support**: LSP integration for Nix, TypeScript/JavaScript, Lua, and Python
- **Fuzzy Finding**: Telescope integration for files, buffers, symbols, and more
- **Advanced Completion**: Blink.cmp for fast, intelligent autocompletion
- **Terminal Integration**: ToggleTerm for seamless terminal management
- **Git Workflow**: Lazygit integration with automatic colorscheme theming
- **File Management**: Neo-tree for modern file exploration
- **Syntax Highlighting**: Treesitter for accurate, context-aware highlighting
- **Keymap Discovery**: WhichKey for interactive keybinding discovery and documentation

### Design Philosophy

1. **Performance First**: Lazy loading and optimized configurations
2. **Reproducible**: Nix manages system dependencies, plugins are locked
3. **Maintainable**: Modular plugin architecture with clear separation
4. **User-Friendly**: Intuitive keymaps and visual feedback
5. **IDE-Quality**: Full language server integration with modern UX

## Architecture

### Hybrid Management Approach

This configuration uses a three-tier approach to dependency management:

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Nix/Nixpkgs   │    │  Home Manager   │    │   lazy.nvim     │
│                 │    │                 │    │                 │
│ • Language      │    │ • File linking  │    │ • Editor        │
│   Servers       │    │ • Configuration │    │   Plugins       │
│ • System Tools  │    │ • Integration   │    │ • UI Plugins    │
│ • Formatters    │    │ • Shell Aliases │    │ • Lazy Loading  │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

**Why This Approach?**

- **Nix**: Manages system-level tools (LSP servers, formatters) for reproducibility
- **Home Manager**: Handles file linking and system integration
- **lazy.nvim**: Provides fast, flexible plugin management with lazy loading

### File Organization

```
home/modules/editors/
├── neovim.nix                 # Main Nix configuration
├── shared-vim-config.vim      # Base vim configuration
├── lua/plugins/               # Plugin configurations
│   ├── init.lua              # Plugin loader
│   ├── telescope.lua         # Fuzzy finder
│   ├── treesitter.lua        # Syntax highlighting
│   ├── lsp.lua               # Language servers
│   ├── completion.lua        # Autocompletion
│   ├── lualine.lua           # Statusline
│   ├── catppuccin.lua        # Colorscheme
│   ├── neo-tree.lua          # File explorer
│   ├── toggleterm.lua        # Terminal management
│   └── snacks.lua            # Lazygit integration
└── README.md                 # This documentation
```

### Plugin Loading Strategy

The configuration uses lazy.nvim's advanced loading capabilities:

- **Immediate Loading**: Core UI plugins (colorscheme, statusline)
- **Event-Based**: LSP and completion load on file events
- **Command-Based**: Utilities load when commands are executed
- **Key-Based**: Features load when keymaps are pressed

## Quick Start

### Prerequisites

- Nix with flakes enabled
- Home Manager configured
- Git for plugin management

### Installation

This configuration is part of a larger Nix/Home Manager setup. To enable:

1. Include the neovim module in your Home Manager configuration
2. Rebuild your system: `sudo darwin-rebuild switch --flake .#your-host`
3. Launch neovim: `nvim` or `nv`

### First Launch

On first launch, lazy.nvim will automatically:
1. Install all configured plugins
2. Set up language servers
3. Download treesitter parsers
4. Configure completion sources

This process takes 1-2 minutes and only happens once.

### Essential Keymaps

Get started with these essential keymaps:

| Keymap | Action | Plugin |
|--------|--------|--------|
| `<leader>ff` | Find files | Telescope |
| `<leader>fg` | Live grep | Telescope |
| `<leader>fb` | Find buffers | Telescope |
| `<leader>e` | Toggle file explorer | Neo-tree |
| `<leader>t` | Toggle terminal | ToggleTerm |
| `<leader>ai` | Claude AI terminal | Custom |
| `<leader>gg` | Open lazygit | Snacks |
| `gd` | Go to definition | LSP |
| `gr` | Find references | LSP |
| `K` | Show hover documentation | LSP |

## Plugin Documentation

### Core Infrastructure

#### lazy.nvim - Plugin Manager
- **Repository**: [folke/lazy.nvim](https://github.com/folke/lazy.nvim)
- **Purpose**: Modern plugin manager with lazy loading and performance optimization

**Key Features**:
- Lazy loading based on commands, events, and keymaps
- Automatic plugin installation and updates

#### WhichKey - Keymap Discovery
- **Repository**: [folke/which-key.nvim](https://github.com/folke/which-key.nvim)
- **Purpose**: Interactive keybinding discovery and documentation

**Key Features**:
- Press `<leader>` (space) to see all available keybindings
- Organized groups for related functionality (e.g., Window Management)
- Buffer-local keymap discovery with `<leader>?`

**Maintenance Note**: When adding new keybindings to `neovim.nix`, corresponding descriptions must be added to `lua/plugins/which-key.lua` to maintain accurate documentation.
- Lock file for reproducible plugin versions
- Performance profiling and optimization
- Beautiful UI for plugin management

**Commands**:
- `:Lazy` - Open plugin manager interface
- `:Lazy update` - Update all plugins
- `:Lazy sync` - Install missing and update existing plugins
- `:Lazy profile` - View plugin loading performance

#### Catppuccin - Colorscheme
- **Repository**: [catppuccin/nvim](https://github.com/catppuccin/nvim)
- **Purpose**: Modern, warm colorscheme with excellent contrast

**Configuration**:
- **Flavor**: Mocha (dark theme with warm undertones)
- **Transparency**: Disabled for better readability
- **Terminal Colors**: Enabled for consistent theming
- **Integrations**: Configured for all installed plugins

**Features**:
- Optimized for long coding sessions
- Consistent colors across all plugins
- Support for semantic highlighting
- Automatic integration with terminal applications

### Development Environment

#### Telescope - Fuzzy Finder
- **Repository**: [nvim-telescope/telescope.nvim](https://github.com/nvim-telescope/telescope.nvim)
- **Purpose**: Highly extendable fuzzy finder for files, buffers, symbols, and more

**Configuration**:
- **FZF Native**: Native FZF sorter for better performance
- **File Ignore Patterns**: Excludes .git/, node_modules/, .cache/
- **Hidden Files**: Enabled in find_files picker
- **Live Grep**: Uses ripgrep for fast text searching

**Key Keymaps**:
- `<leader>ff` - Find files in current directory
- `<leader>fb` - Find open buffers
- `<leader>fg` - Live grep in current directory
- `<leader>fh` - Search help tags
- `<leader>fc` - Search available commands
- `<leader>fk` - Search keymaps
- `<leader>gf` - Find git-tracked files
- `<leader>gc` - Browse git commits
- `<leader>gb` - Browse git branches

**LSP Integration**:
- `<leader>ls` - Document symbols
- `<leader>lw` - Workspace symbols
- `<leader>ld` - Diagnostics
- `<leader>li` - Implementations
- `<leader>lt` - Type definitions

#### Neo-tree - File Explorer
- **Repository**: [nvim-neo-tree/neo-tree.nvim](https://github.com/nvim-neo-tree/neo-tree.nvim)
- **Purpose**: Modern file explorer with git integration and multiple views

**Configuration**:
- **Position**: Left sidebar
- **Width**: 30 characters
- **Auto Close**: Closes when last buffer is closed
- **Git Integration**: Shows git status indicators
- **Follow Current File**: Automatically reveals current file

**Key Features**:
- Filesystem navigation with intuitive controls
- Git status integration (modified, staged, untracked files)
- Buffer management view
- Quick file operations (create, delete, rename, copy)

**Keymaps** (in Neo-tree):
- `<CR>` - Open file or toggle directory
- `o` - Open file in new split
- `v` - Open file in vertical split
- `a` - Create new file/directory
- `d` - Delete file/directory
- `r` - Rename file/directory
- `c` - Copy file/directory
- `x` - Cut file/directory
- `p` - Paste file/directory

#### Treesitter - Syntax Highlighting
- **Repository**: [nvim-treesitter/nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter)
- **Purpose**: Advanced syntax highlighting and code navigation using tree-sitter parsers

**Installed Languages**:
- Nix (`.nix` files)
- TypeScript/JavaScript (`.ts`, `.js`, `.tsx`, `.jsx`)
- Lua (`.lua` files)
- Python (`.py` files)
- Markdown (`.md` files)
- JSON (`.json` files)
- YAML (`.yml`, `.yaml` files)
- HTML (`.html` files)
- CSS (`.css` files)

**Features**:
- **Accurate Highlighting**: Context-aware syntax highlighting
- **Code Folding**: Intelligent folding based on syntax tree
- **Incremental Selection**: Smart text object selection
- **Auto-install**: Parsers install automatically when needed

**Configuration**:
- Folding enabled with treesitter expressions
- High fold level (99) for open folds by default
- Incremental selection for expanding text objects

#### LSP - Language Server Protocol
- **Repository**: [neovim/nvim-lspconfig](https://github.com/neovim/nvim-lspconfig)
- **Purpose**: Language server integration for intelligent code features

**Configured Language Servers**:

1. **nixd** - Nix Language Server
   - Advanced Nix language support
   - Flake-aware completion and diagnostics
   - Integration with system Nix installation

2. **typescript-language-server** - TypeScript/JavaScript
   - Full TypeScript and JavaScript support
   - React and Node.js integration
   - Advanced refactoring capabilities

3. **lua-language-server** - Lua
   - Neovim API integration
   - Advanced Lua diagnostics
   - Optimized for Neovim configuration

4. **python-lsp-server** - Python
   - Comprehensive Python language support
   - Plugin ecosystem for additional features
   - Integration with popular Python tools

**LSP Features**:
- **Go to Definition** (`gd`) - Jump to symbol definition
- **Find References** (`gr`) - Find all symbol references
- **Hover Documentation** (`K`) - Show symbol documentation
- **Rename Symbol** (`<leader>rn`) - Rename symbol across workspace
- **Code Actions** (`<leader>ca`) - Show available code actions
- **Format Document** (`<leader>f`) - Format current document

**Diagnostic Navigation**:
- `]d` - Next diagnostic
- `[d` - Previous diagnostic
- `<leader>dl` - Diagnostics location list
- `<leader>df` - Show diagnostic in floating window

#### Blink.cmp - Completion Engine
- **Repository**: [saghen/blink.cmp](https://github.com/saghen/blink.cmp)
- **Purpose**: Fast, modern completion engine with advanced features

**Why Blink.cmp over nvim-cmp?**
- **Performance**: 10-20x faster completion rendering
- **Memory Efficiency**: Lower memory usage
- **Modern Architecture**: Built for Neovim's latest features
- **Fuzzy Matching**: Advanced fuzzy matching with typo tolerance
- **Frecency Sorting**: Intelligent ranking based on usage patterns

**Completion Sources** (in priority order):
1. **LSP** - Language server completions
2. **Path** - File system path completions
3. **Snippets** - LuaSnip snippet completions
4. **Buffer** - Current buffer text completions

**Key Features**:
- **Fuzzy Matching**: Finds completions even with typos
- **Proximity Scoring**: Prefers completions from nearby text
- **Semantic Tokens**: Uses LSP semantic information
- **Auto-brackets**: Automatically inserts function parentheses
- **Snippet Support**: Full LuaSnip integration

**Keymaps** (in completion menu):
- `<C-n>` / `<C-p>` - Navigate completion items
- `<C-e>` - Close completion menu
- `<CR>` - Accept completion
- `<Tab>` - Navigate snippet placeholders

### UI & Workflow

#### Lualine - Statusline
- **Repository**: [nvim-lualine/lualine.nvim](https://github.com/nvim-lualine/lualine.nvim)
- **Purpose**: Fast, customizable statusline with rich information display

**Configuration**:
- **Theme**: Catppuccin integration for consistent colors
- **Sections**: Mode, git branch, filename, diagnostics, file type, progress
- **Git Integration**: Shows current branch and change counts
- **LSP Integration**: Displays active language servers

**Statusline Sections**:
```
┌─────────┬──────────┬─────────────┬───────────────┬──────────┬─────────┐
│  Mode   │ Git Info │  Filename   │ Diagnostics   │ LSP Info │Progress │
│ NORMAL  │  main    │ init.lua    │ ✓ 2 ⚠ 1 ✗ 0  │   lua    │  45%    │
└─────────┴──────────┴─────────────┴───────────────┴──────────┴─────────┘
```

**Features**:
- **Mode Indicators**: Visual indication of current mode
- **Git Status**: Branch name and change statistics
- **Diagnostic Summary**: Error, warning, and info counts
- **File Information**: Name, type, and encoding
- **Progress**: Current line/column and percentage through file

#### ToggleTerm - Terminal Management
- **Repository**: [akinsho/toggleterm.nvim](https://github.com/akinsho/toggleterm.nvim)
- **Purpose**: Enhanced terminal management with multiple orientations and persistent sessions

**Configuration**:
- **Default Direction**: Horizontal split
- **Primary Toggle**: `<leader>t` for quick access
- **Alternative Toggle**: `<F12>` for universal access
- **Size**: 15 lines for horizontal, 40% width for vertical
- **Shell Integration**: Uses system shell

**Claude AI Terminal**:
- **Purpose**: Custom terminal designed for Claude Code integration
- **Toggle**: `<leader>ai` - Independent of ToggleTerm plugin
- **Layout**: Vertical split with 40-column width
- **Persistence**: Terminal session persists when toggled off
- **Implementation**: Native Neovim terminal functionality

**Terminal Orientations**:
- **Horizontal** (`<leader>t`, `<leader>Th`) - Split below current window
- **Vertical** (`<leader>Tv`) - Split to the right
- **Claude AI** (`<leader>ai`) - Custom vertical terminal for Claude Code (40-column persistent)
- **Floating** (`<leader>Tf`) - Floating window with curved borders
- **Tab** (`<leader>Tt`) - Full tab terminal

**Multiple Terminals**:
- `<leader>T1` - Terminal instance 1
- `<leader>T2` - Terminal instance 2
- `<leader>T3` - Terminal instance 3

**Terminal Navigation** (when in terminal):
- `<Esc>` - Return to normal mode
- `<C-h/j/k/l>` - Navigate between windows
- Standard terminal commands work as expected

**Features**:
- **Persistent Sessions**: Terminals maintain state when toggled
- **Window Integration**: Seamless integration with Neovim windows
- **Multiple Instances**: Support for multiple concurrent terminals
- **Flexible Sizing**: Responsive sizing based on orientation

#### Snacks.nvim - Lazygit Integration
- **Repository**: [folke/snacks.nvim](https://github.com/folke/snacks.nvim)
- **Purpose**: Quality of life improvements, specifically lazygit integration

**Configuration**:
- **Minimal Setup**: Only lazygit module enabled
- **Auto-theming**: Lazygit inherits Neovim colorscheme
- **Editor Integration**: Files opened in lazygit use current Neovim session

**Lazygit Features**:
- **Keymap**: `<leader>gg` - Open lazygit
- **Automatic Theming**: Matches current Catppuccin colorscheme
- **Seamless Editing**: Edit files within current Neovim session
- **Git Workflow**: Complete git operations within familiar interface

**Available Commands**:
- `:lua Snacks.lazygit()` - Open lazygit
- `:lua Snacks.lazygit.log()` - Open lazygit log view
- `:lua Snacks.lazygit.log_file()` - Open log for current file

## Keymap Reference

### Leader Key Mappings

The leader key is `\` (backslash). All leader mappings are organized by category:

#### File Operations
| Keymap | Action | Plugin |
|--------|--------|--------|
| `<leader>w` | Save file | Built-in |
| `<leader>so` | Source config | Built-in |
| `<leader>e` | Toggle file explorer | Neo-tree |

#### AI Integration
| Keymap | Action | Plugin |
|--------|--------|--------|
| `<leader>ai` | Claude AI terminal | Custom |

#### Buffer Management
| Keymap | Action | Plugin |
|--------|--------|--------|
| `<leader>bn` | Next buffer | Built-in |
| `<leader>bp` | Previous buffer | Built-in |
| `<leader>bd` | Delete buffer | Built-in |

#### Telescope (Fuzzy Finding)
| Keymap | Action | Description |
|--------|--------|-------------|
| `<leader>ff` | Find files | Search files in current directory |
| `<leader>fb` | Find buffers | Search open buffers |
| `<leader>fg` | Live grep | Search text across files |
| `<leader>fh` | Help tags | Search help documentation |
| `<leader>fc` | Commands | Search available commands |
| `<leader>fk` | Keymaps | Search configured keymaps |

#### Git Operations
| Keymap | Action | Plugin |
|--------|--------|--------|
| `<leader>gg` | Open lazygit | Snacks |
| `<leader>gf` | Git files | Telescope |
| `<leader>gc` | Git commits | Telescope |
| `<leader>gb` | Git branches | Telescope |

#### LSP (Language Server)
| Keymap | Action | Description |
|--------|--------|-------------|
| `<leader>ls` | Document symbols | Search symbols in current file |
| `<leader>lw` | Workspace symbols | Search symbols in workspace |
| `<leader>ld` | Diagnostics | Show all diagnostics |
| `<leader>li` | Implementations | Find implementations |
| `<leader>lt` | Type definitions | Find type definitions |
| `<leader>rn` | Rename symbol | Rename symbol across workspace |
| `<leader>ca` | Code actions | Show available code actions |
| `<leader>f` | Format document | Format current file |

#### Diagnostics
| Keymap | Action | Description |
|--------|--------|-------------|
| `<leader>dl` | Diagnostic list | Open diagnostics in location list |
| `<leader>df` | Diagnostic float | Show diagnostic in floating window |

#### Terminal Management
| Keymap | Action | Description |
|--------|--------|-------------|
| `<leader>t` | Toggle terminal | Horizontal terminal (primary) |
| `<leader>ai` | Claude AI terminal | Custom vertical terminal for Claude Code |
| `<leader>Tf` | Floating terminal | Terminal in floating window |
| `<leader>Th` | Horizontal terminal | Terminal in horizontal split |
| `<leader>Tv` | Vertical terminal | Terminal in vertical split |
| `<leader>Tt` | Tab terminal | Terminal in new tab |
| `<leader>T1` | Terminal 1 | First terminal instance |
| `<leader>T2` | Terminal 2 | Second terminal instance |
| `<leader>T3` | Terminal 3 | Third terminal instance |

#### Folding
| Keymap | Action | Description |
|--------|--------|-------------|
| `<leader>zo` | Open fold | Open fold at cursor |
| `<leader>zc` | Close fold | Close fold at cursor |
| `<leader>za` | Open all folds | Open all folds in buffer |
| `<leader>zm` | Close all folds | Close all folds in buffer |

### Function Keys
| Keymap | Action | Plugin |
|--------|--------|--------|
| `<F12>` | Toggle terminal | ToggleTerm |

### Navigation Keys
| Keymap | Action | Context |
|--------|--------|---------|
| `<C-h/j/k/l>` | Navigate windows | Normal mode |
| `<C-h/j/k/l>` | Navigate from terminal | Terminal mode |
| `gd` | Go to definition | LSP |
| `gr` | Find references | LSP |
| `gi` | Go to implementation | LSP |
| `gt` | Go to type definition | LSP |
| `K` | Show hover documentation | LSP |

### Diagnostic Navigation
| Keymap | Action | Description |
|--------|--------|-------------|
| `]d` | Next diagnostic | Jump to next error/warning |
| `[d` | Previous diagnostic | Jump to previous error/warning |

### Terminal Mode
| Keymap | Action | Description |
|--------|--------|-------------|
| `<Esc>` | Exit terminal mode | Return to normal mode |
| `<C-h/j/k/l>` | Navigate windows | Move between windows from terminal |

### Completion (in completion menu)
| Keymap | Action | Description |
|--------|--------|-------------|
| `<C-n>` | Next completion | Navigate down in completion menu |
| `<C-p>` | Previous completion | Navigate up in completion menu |
| `<C-e>` | Close completion | Close completion menu |
| `<CR>` | Accept completion | Accept selected completion |
| `<Tab>` | Next snippet placeholder | Navigate snippet placeholders |

## Language Support

This configuration provides comprehensive language support through LSP integration:

### Nix
- **Language Server**: nixd
- **Features**: Flake-aware completion, diagnostics, formatting
- **File Types**: `.nix`
- **Special Features**: Integration with system Nix installation

### TypeScript/JavaScript
- **Language Server**: typescript-language-server
- **Features**: Full TypeScript support, React integration, refactoring
- **File Types**: `.ts`, `.tsx`, `.js`, `.jsx`
- **Special Features**: Node.js and React-specific completions

### Lua
- **Language Server**: lua-language-server
- **Features**: Neovim API integration, advanced diagnostics
- **File Types**: `.lua`
- **Special Features**: Optimized for Neovim configuration files

### Python
- **Language Server**: python-lsp-server
- **Features**: Comprehensive Python support, plugin ecosystem
- **File Types**: `.py`
- **Special Features**: Integration with popular Python tools

### Additional Languages (via Treesitter)
- **Markdown**: Syntax highlighting and folding
- **JSON**: Syntax highlighting and error detection
- **YAML**: Syntax highlighting and structure validation
- **HTML/CSS**: Web development support

## Customization Guide

### Adding New Plugins

1. Create a new plugin file in `lua/plugins/`:
```lua
-- lua/plugins/my-plugin.lua
return {
  'author/plugin-name',
  event = 'VeryLazy', -- or other loading strategy
  config = function()
    require('plugin-name').setup({
      -- plugin configuration
    })
  end,
}
```

2. Add the file mapping to `neovim.nix`:
```nix
home.file = {
  # ... existing mappings
  ".config/nvim/lua/plugins/my-plugin.lua".source = ./lua/plugins/my-plugin.lua;
};
```

3. Rebuild your system:
```bash
sudo darwin-rebuild switch --flake .#your-host
```

### Adding New Language Servers

1. Add the language server package to `neovim.nix`:
```nix
extraPackages = with pkgs; [
  # ... existing packages
  your-language-server
];
```

2. Configure the LSP in `lua/plugins/lsp.lua`:
```lua
-- Add to the configuration function
lspconfig.your_ls.setup({
  capabilities = capabilities,
  on_attach = on_attach,
  -- language-specific settings
})
```

3. Rebuild and restart Neovim.

### Modifying Keymaps

Keymaps can be modified in the relevant plugin files:

- **Global keymaps**: `neovim.nix` extraConfig section
- **Plugin-specific keymaps**: Individual plugin configuration files
- **LSP keymaps**: `lua/plugins/lsp.lua` on_attach function

### Changing Colorscheme

To change from Catppuccin to another colorscheme:

1. Modify `lua/plugins/catppuccin.lua` or create a new colorscheme file
2. Update the colorscheme name in the configuration
3. Ensure the new colorscheme integrates with other plugins

### Performance Tuning

- **Lazy Loading**: Use appropriate loading strategies in plugin configurations
- **Disabled Plugins**: Add unwanted built-in plugins to the disabled list in `neovim.nix`
- **LSP Optimization**: Adjust LSP settings for large codebases
- **Treesitter**: Only install parsers for languages you use

## Troubleshooting

### Common Issues

#### Plugins Not Loading
**Symptoms**: Plugins appear to be configured but don't work
**Solution**: 
1. Check file mappings in `neovim.nix`
2. Verify plugin files exist and are valid Lua
3. Run `:Lazy` to check plugin status
4. Check for errors with `:checkhealth`

#### LSP Not Working
**Symptoms**: No completion, diagnostics, or LSP features
**Solution**:
1. Verify language server is installed: `:LspInfo`
2. Check if LSP attaches to buffer: `:LspInfo` in relevant file
3. Verify language server binary exists in PATH
4. Check LSP logs: `:LspLog`

#### Slow Performance
**Symptoms**: Neovim feels sluggish or takes long to start
**Solution**:
1. Profile plugin loading: `:Lazy profile`
2. Check for heavy plugins loading immediately
3. Optimize loading strategies (use events, commands, keys)
4. Disable unused features in plugin configurations

#### Completion Not Working
**Symptoms**: No completion suggestions appear
**Solution**:
1. Verify blink.cmp is loaded: `:lua print(vim.inspect(require('blink.cmp')))`
2. Check completion sources are available
3. Verify LSP is attached for LSP completions
4. Check snippet engine (LuaSnip) is working

#### Terminal Issues
**Symptoms**: Terminal doesn't open or behaves incorrectly
**Solution**:
1. Check ToggleTerm configuration
2. Verify shell is correctly set
3. Test with different terminal orientations
4. Check for keymap conflicts

#### Git Integration Problems
**Symptoms**: Lazygit doesn't open or lacks theming
**Solution**:
1. Verify lazygit is installed system-wide
2. Check Snacks.nvim configuration
3. Ensure git repository is valid
4. Test manual lazygit command

### Diagnostic Commands

Use these commands to diagnose issues:

- `:checkhealth` - Comprehensive health check
- `:Lazy` - Plugin manager interface
- `:LspInfo` - LSP status and attached servers
- `:LspLog` - LSP server logs
- `:Telescope diagnostics` - All diagnostics
- `:lua vim.print(vim.api.nvim_get_runtime_file("", true))` - Runtime path

### Getting Help

1. **Built-in Help**: Use `:help` followed by topic
2. **Plugin Documentation**: Most plugins have extensive documentation
3. **LSP Issues**: Check language server specific documentation
4. **Performance**: Use built-in profiling tools

### Backup and Recovery

The configuration files are managed by Nix and Home Manager, providing automatic backup through version control. To restore:

1. **Git History**: Use git to revert problematic changes
2. **Nix Generations**: Rollback Home Manager generations
3. **Plugin Lockfile**: Use `lazy-lock.json` for consistent plugin versions

## Performance Characteristics

### Startup Time
- **Cold Start**: ~150-250ms (first time, downloading plugins)
- **Warm Start**: ~50-80ms (typical startup)
- **Optimizations**: Lazy loading, minimal immediate plugins

### Memory Usage
- **Base**: ~15-25MB (minimal configuration)
- **With Plugins**: ~30-50MB (typical usage)
- **LSP Active**: +10-20MB per language server

### Plugin Loading
- **Immediate**: Colorscheme, statusline (~10ms)
- **On Event**: LSP, completion (~50-100ms when triggered)
- **On Demand**: File explorer, terminal (~20-50ms when used)

## Architecture Benefits

### Reproducibility
- **Nix Packages**: Exact versions of system tools
- **Plugin Lockfile**: Exact versions of editor plugins
- **Configuration**: Version controlled, atomic updates

### Maintainability
- **Modular Design**: Each plugin in separate file
- **Clear Separation**: System tools vs editor plugins
- **Documentation**: Comprehensive inline documentation

### Performance
- **Lazy Loading**: Plugins load only when needed
- **Optimized Defaults**: Performance-first configurations
- **Minimal Overhead**: Only necessary features enabled

### User Experience
- **Intuitive Keymaps**: Logical, memorable shortcuts
- **Visual Feedback**: Clear status indicators
- **IDE Features**: Complete language server integration

This configuration balances power, performance, and usability to provide a world-class development environment while remaining maintainable and approachable for developers of all skill levels.