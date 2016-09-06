" vimrc
" Brian Gesiak <modocache@gmail.com>
" vim: set tabstop=8 softtabstop=2 shiftwidth=2 expandtab nowrap:

scriptencoding utf-8  " this file is in utf-8

" ---- Installation Instructions ----
" 1. mkdir -p ~/.vim/backups ~/.vim/swaps ~/.vim/undo
" 2. This .vimrc requires Vundle. You may install Vundle using the following
"    command:
"        git clone https://github.com/VundleVim/Vundle.vim.git \
"            ~/.vim/bundle/Vundle.vim
" 3. Open Vim and run :PluginInstall.
" 4. Some plugins require additional setup:
"    * wincent/Command-T: You'll need to have compiled Vim with Ruby support
"                         enabled. On Linux, `apt-get install vim.nox` is an
"                         alternative to comiling from source. You'll also need
"                         `apt-get install ruby2.1-dev`.
"
"                         Once you've installed those:
"                             cd ~/.vim/bundle/Command-T/ruby/command-t
"                             ruby extconf.rb
"                             make
"    * Valloric/YouCompleteMe: Run the following commands:
"                                  cd ~/.vim/bundle/YouCompleteMe
"                                  ./install.py --clang-completer
"                              You'll also want to add a .ycm_extra_config.py
"                              to your ~/.vim directory.
"    * Lokaltog/powerline: You'll need to install patched fonts on your
"                          system:
"                              git clone https://github.com/powerline/fonts.git
"                              cd fonts
"                              ./install.sh
"                          Then, set your terminal's font to one of the
"                          patched fonts. My favorite is Meslo LG S Regular
"                          for Powerline, 12pt.

" ---- Vundle Setup ----
set nocompatible  " Don't emulate vi's limitations. This is also required for
                  " Vundle setup.
filetype off  " Required for Vundle. This is re-enabled further down.

set rtp+=~/.vim/bundle/Vundle.vim  " Include Vundle in the runtime path.
call vundle#begin()  " Initialize Vundle.

Plugin 'gmarik/Vundle.vim'  " This plugin is required by Vundle itself.
Plugin 'flazz/vim-colorschemes'  " Includes the CandyPaper color scheme, but for
                                 " some reason this theme looks better than
                                 " when I include dfxyz/CandyPaper.vim
                                 " directly.
Plugin 'scrooloose/nerdtree'  " Tree explorer.
Plugin 'wincent/Command-T'  " Fuzzy file finder.
Plugin 'vim-scripts/AutoTag'  " Updates ctags entires automatically when saving.
Plugin 'majutsushi/tagbar'  " Displays tags in a file in the sidebar.
Plugin 'vim-scripts/TagHighlight'  " Enhanced syntax highlighting by parsing
                                   " ctags.
Plugin 'Valloric/YouCompleteMe'  " Autocompletion for many languages, most
                                 " notably C/C++/Objective-C via libclang.
Plugin 'ntpeters/vim-better-whitespace'  " Highlights trailing whitespace.
Plugin 'Lokaltog/powerline', {'rtp': 'powerline/bindings/vim/'}  " Fancy status
                                                                 " line.
Plugin 'octol/vim-cpp-enhanced-highlight'  " Additional syntax highlighting for
                                           " C++.
Plugin 'keith/swift.vim'  " Syntax highlighting for Swift.
                          " FIXME: Use swift/utils/vim instead.

call vundle#end()  " Finish defining plugins.
filetype plugin indent on  " Required for Vundle.

" ---- Valloric/YouCompleteMe Setup ----
let g:ycm_global_ycm_extra_conf = "~/.vim/.ycm_extra_conf.py"  " Not actually
                                                               " used. Copy
                                                               " this into
                                                               " your
                                                               " project's
                                                               " root
                                                               " directory.
let g:ycm_autoclose_preview_window_after_completion = 1  " Auto-close the
                                                         " preview window once
                                                         " a completion has
                                                         " been selected.
let g:ycm_filepath_completion_use_working_dir = 1  " Use the current working
                                                   " directory when
                                                   " autocompleting file
                                                   " paths.
let g:ycm_collect_identifiers_from_tags_files = 1  " Use ctags identifiers when
                                                   " available.
let g:ycm_confirm_extra_conf = 0  " Trust .ycm_extra_conf.py scripts in project
                                  " roots.
" let g:ycm_server_use_vim_stdout = 1   " Uncomment these two settings
" let g:ycm_server_log_level = 'debug'  " to debug.

" ---- scrooloose/nerdtree Setup ----
let NERDTreeShowHidden=1    " Show hidden files
let NERDTreeIgnore=['\.py[co]$', '^__pycache__$', '\.DS_Store', '\.swp$']

" ---- Lokaltog/powerline Setup ----
set laststatus=2  " Always include a status line; Powerline uses it to display
                  " its fancy one.

" ---- octol/vim-cpp-enhanced-highlight Setup ----
let g:cpp_class_scope_highlight = 1

" ---- Terminal Setup ----
if (&term =~ "xterm") && (&termencoding == "")
  set termencoding=utf-8
endif

" ---- Keybindings Setup ----
map <leader>1 :NERDTreeToggle<CR>  " \1 toggles the nerdtree file tree.
map <leader>2 :TagbarToggle<CR>  " \2 toggles the tag list sidebar.
nmap <F3> <C-]>  " F3 jumps to definition uses the ctags binding.
                 " FIXME: Learn to use the ctags binding instead.
map <leader>j :NERDTreeFind<CR>  " \j displays the current file in the file
                                 " tree.

" ---- General Setup ----
set encoding=utf-8  " Default encoding should always be UTF-8.
set mouse=a  " Enable the mouse in all modes.
set t_Co=256  " Use 256 colors.
set background=dark  " Use a dark theme.
colorscheme CandyPaper  " This color scheme is included in
                        " flazz/vim-colorschemes.
set nowrap  " Never wrap lines.
set number  " Display line numbers.
syntax on  " Enable syntax highlighting.
set nostartofline  " Don't reset cursor to the start of the line when moving.
set cursorline  " Highlight the current line.
set ruler  " Show the cursor position.
set colorcolumn=81,121  " Display columns just after 80 and 120 characters.
set esckeys  " Allow cursor keys in insert mode.
set backspace=indent,eol,start  " Allow backspace in insert mode.
set hlsearch  " Highlight searches.
              " FIXME: Use the Gary Bernhardt trick to remove highlight after
              "        hitting the enter key.
set ignorecase  " Ignore case when searching.
set incsearch  " Highlight matches incrementally as pattern is typed.
set noerrorbells  " Disable error bells.
set clipboard=unnamed  " Use the OS clipboard by default (on versions compiled
                       " with `+clipboard`).
set wildmenu  " Enhance command-line completion.
set ttyfast  " Use advanced tty features for smoother drawing.
set shortmess=I  " Don’t show the intro message when starting Vim.
set title  " Show the filename in the window titlebar.
set showcmd  " Show the (partial) command as it’s being typed.
set expandtab  " Use spaces when hitting tab.
set list  " Show invisible characters...
set listchars=tab:▸\ ,trail:▝,eol:¬  " ...but only show tabs and trailing
                                     " whitespace.
set shiftwidth=2  " By default, use two spaces to indent.
set tabstop=2  " By default, tabs are represented by two spaces.
set backupdir=~/.vim/backups  " Place backups, swap files, and undo history at
set directory=~/.vim/swaps    " a specific location.
if exists("&undodir")
  set undodir=~/.vim/undo
endif

" ---- Window Size Setup ----
set winwidth=84     " Set a normal width of 84 columns...
set winminwidth=15  " ...with a minimum of 15 columns.
set winheight=5     " We have to have a winheight bigger than we want to set
set winminheight=5  " winminheight. But if we set winheight to be huge before
set winheight=999   "  winminheight, the winminheight set will fail.

" ---- Markdown Setup ----
au BufRead,BufNewFile *.md set filetype=markdown  " Markdown doesnt seem to be
                                                  " the default for .md files,
                                                  " so explicitly set it.

" ---- Python Setup ----
au Filetype python setl et ts=4 sw=4

