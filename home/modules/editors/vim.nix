_: {
  programs.vim = {
    enable = true;
    extraConfig = ''
      " === SHARED VIM/NEOVIM CONFIGURATION ===
      " This file contains settings that work in both vim and neovim
      " It serves as the canonical source for shared editor behavior

      " === BASIC SETTINGS ===
      
      " Use spaces instead of tabs
      set expandtab

      " Indentation settings
      set tabstop=4           " Number of spaces per tab character
      set shiftwidth=4        " Number of spaces for automatic indentation  
      set softtabstop=4       " Number of spaces inserted when pressing Tab
      set autoindent          " Enable automatic indentation

      " === DISPLAY SETTINGS ===
      
      " Enable syntax highlighting
      syntax on

      " Enable filetype detection and plugins
      filetype plugin indent on

      " Show line numbers
      set number

      " Highlight the current line
      set cursorline

      " Show command in bottom bar
      set showcmd

      " Enable line/column display in status
      set ruler

      " Always show status line
      set laststatus=2

      " Show matching brackets
      set showmatch

      " === SEARCH SETTINGS ===
      
      " Enable incremental search
      set incsearch

      " Smart case-insensitive search
      set ignorecase
      set smartcase

      " Search highlighting behavior (enable on search, disable with //)
      augroup vimrc-incsearch-highlight
        autocmd!
        autocmd CmdlineEnter [/\?] :set hlsearch
        autocmd CmdlineLeave [/\?] :set nohlsearch
      augroup END

      " === EDITING BEHAVIOR ===
      
      " Better backspace behavior
      set backspace=indent,eol,start

      " Don't wrap lines
      set nowrap

      " Enable mouse support where available
      if has('mouse')
        set mouse=a
      endif

      " Encoding
      set encoding=utf-8

      " Show invisible characters
      set list
      set listchars=tab:»·,trail:·,extends:⟩,precedes:⟨

      " === WINDOW BEHAVIOR ===
      
      " Split windows to the right and below
      set splitright
      set splitbelow

      " Reduce redraw frequency
      set lazyredraw

      " === KEY MAPPINGS ===
      
      " Set leader key
      let mapleader = ' '

      " Quick vertical movement
      nnoremap J 5j
      nnoremap K 5k

      " Clear search highlighting
      nnoremap // :nohlsearch<CR>

      " === COMPLETION SETTINGS ===
      
      " Better command-line completion
      set wildmenu
      set wildmode=list:longest,full

      " Completion options
      set completeopt=menuone,longest

      " === FILE HANDLING ===
      
      " Don't create backup files
      set nobackup
      set nowritebackup

      " But do create undo files for persistent undo
      if has('persistent_undo')
        set undofile
        set undodir=~/.vim/undo
        " Create undo directory if it doesn't exist
        if !isdirectory(&undodir)
          call mkdir(&undodir, 'p')
        endif
      endif

      " === COLORSCHEME ===
      
      " Set background (will be overridden by colorscheme)
      set background=dark

      " Try to load colorscheme, fall back gracefully
      try
        colorscheme catppuccin_mocha
      catch
        " Fall back to default colorscheme if catppuccin not available
        colorscheme default
      endtry

      " === PLUGIN-AGNOSTIC SETTINGS ===
      
      " Settings that work well with or without plugins

      " Better grep program if available
      if executable('rg')
        set grepprg=rg\ --vimgrep\ --smart-case
        set grepformat=%f:%l:%c:%m
      elseif executable('ag')
        set grepprg=ag\ --vimgrep
        set grepformat=%f:%l:%c:%m
      endif

      " === AUTOCOMMANDS ===
      
      augroup vimrc_auto_commands
        autocmd!

        " Return to last edit position when opening files
        autocmd BufReadPost *
          \ if line("'\"") > 0 && line("'\"") <= line("$") |
          \   exe "normal! g`\"" |
          \ endif

        " Remove trailing whitespace on save for certain filetypes
        autocmd BufWritePre *.py,*.js,*.ts,*.nix,*.rs,*.go :%s/\s\+$//e

        " Set specific indentation for certain filetypes
        autocmd FileType nix setlocal shiftwidth=2 tabstop=2 softtabstop=2
        autocmd FileType yaml setlocal shiftwidth=2 tabstop=2 softtabstop=2
        autocmd FileType json setlocal shiftwidth=2 tabstop=2 softtabstop=2

      augroup END

      " === CUSTOM FUNCTIONS ===
      
      " Toggle between relative and absolute line numbers
      function! ToggleLineNumbers()
        if &relativenumber
          set norelativenumber
          set number
        else
          set relativenumber
        endif
      endfunction

      " Quick toggle for line numbers
      nnoremap <Leader>ln :call ToggleLineNumbers()<CR>

      " === STATUS LINE (fallback if no plugin) ===
      
      " Custom status line if no plugin is available
      if !exists('g:loaded_airline') && !exists('g:loaded_lightline') && !exists('g:loaded_lualine')
        set statusline=%f\ %m%r%h%w\ [%Y]\ [%{&ff}]\ %=[%l,%c]\ [%p%%]\ [%L\ lines]
      endif

      " === LOAD LOCAL CUSTOMIZATIONS ===
      
      " Source local vimrc if it exists (for machine-specific settings)
      if filereadable(expand('~/.vimrc.local'))
        source ~/.vimrc.local
      endif
    '';
  };
}
