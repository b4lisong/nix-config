{ ... }:
{
  programs.vim = {
    enable = true;
    settings = {
      expandtab = true;
      tabstop = 4;
      shiftwidth = 4;
      number = true;
    };
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
}
