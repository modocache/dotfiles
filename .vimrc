" vimrc
" Brian Gesiak <modocache@gmail.com>
" vim: set tabstop=8 softtabstop=2 shiftwidth=2 expandtab nowrap:

scriptencoding utf-8  " this file is in utf-8

" ---- Installation Instructions ----
" 1. mkdir -p ~/.vim/backups ~/.vim/swaps ~/.vim/undo
" 2. This .vimrc requires Vundle. You may install Vundle using the following
"    command:
"
"      git clone https://github.com/VundleVim/Vundle.vim.git \
"            ~/.vim/bundle/Vundle.vim
"
" 3. Open Vim and run :PluginInstall.
" 4. Some plugins require additional setup:
"    4.1. Valloric/YouCompleteMe
"         Run the following commands:
"
"           cd ~/.vim/bundle/YouCompleteMe
"           python3 ./install.py --clang-completer --ninja
"
"         (Last time I evaluated it, on April 8 2020, the '--clangd-completer'
"         was slow to the point of being unusable for llvm-project.)
"         To enable completion for any project, add a symlink to
"         'compile_commands.json' from the root directory within which you're
"         opening Vim. For llvm-project, that would mean:
"
"           cd llvm-project
"           ln -s build/compile_commands.json compile_commands.json
"
" 5. It's not necessary for any of this to work, but if you wish, you may
"    build and install Vim from source. To do so:
"
"      git clone https://github.com/vim/vim.git
"      cd vim
"      vim Makefile       # Toggle options to '--enable-python3interp', etc.
"      make
"      sudo make install  # To uninstall, 'sudo make uninstall'
"
" ---- Vundle Setup ----
set nocompatible  " Don't emulate vi's limitations. This is also required for
                  " Vundle setup.
filetype off  " Required for Vundle. This is re-enabled further down.

set shell=/bin/bash  " Vundle's commands, such as :PluginInstall, do not work
                     " in fish shell. See:
                     " https://github.com/VundleVim/Vundle.vim/issues/690
set rtp+=~/.vim/bundle/Vundle.vim  " Include Vundle in the runtime path.
call vundle#begin('~/.vim/bundle')  " Initialize Vundle.

Plugin 'gmarik/Vundle.vim'  " This plugin is required by Vundle itself.
Plugin 'flazz/vim-colorschemes'  " Includes the CandyPaper color scheme, but for
                                 " some reason this theme looks better than
                                 " when I include dfxyz/CandyPaper.vim
                                 " directly.
Plugin 'ctrlpvim/ctrlp.vim.git'  " Fuzzy finder.
Plugin 'FelikZ/ctrlp-py-matcher'  " The default matcher in ctrlp.vim is
                                  " god awful. 'opt.cpp' doesn't find the file
                                  " 'tools/opt/opt.cpp'...?! Replace it with
                                  " something reasonable.
Plugin 'scrooloose/nerdtree'  " Tree explorer.
Plugin 'tpope/vim-fugitive'  " Git integration.
Plugin 'tomtom/tcomment_vim'  " Comment out blocks of code.
Plugin 'majutsushi/tagbar'  " Displays tags in a file in the sidebar.
Plugin 'vim-scripts/TagHighlight'  " Enhanced syntax highlighting by parsing
                                   " ctags.
Plugin 'Valloric/YouCompleteMe'  " Autocompletion for many languages, most
                                 " notably C/C++/Objective-C via libclang.
Plugin 'rust-lang/rust.vim'  " Rust file detection and syntax highlighting.
Plugin 'apple/swift', {'rtp': 'utils/vim'}  " Syntax highlighting for Swift,
                                            " SIL, and .gyb files.
" Syntax highlighting for LLVM *.ll and tablegen *.td files.
Plugin 'llvm/llvm-project', {'rtp': 'llvm/utils/vim'}

call vundle#end()  " Finish defining plugins.
filetype plugin indent on  " Required for Vundle.

" ---- Valloric/YouCompleteMe Setup ----
let g:ycm_use_clangd = 0  " Use libclang, not clangd. As I mention above,
                          " the clangd completer is slow.
let g:ycm_autoclose_preview_window_after_completion = 1  " Auto-close the
                                                         " preview window once
                                                         " a completion has
                                                         " been selected.
let g:ycm_autoclose_preview_window_after_insertion = 1  " Auto-close the
                                                        " preview window when
                                                        " exiting insert mode.
let g:ycm_filepath_completion_use_working_dir = 1  " Use the current working
                                                   " directory when
                                                   " autocompleting file
                                                   " paths.
let g:ycm_enable_diagnostic_signs = 0 " Don't put any symbols into the Vim
                                      " gutter on lines that contain errors,
                                      " since that shifts the Vim panes around
                                      " in a way I don't like.
" let g:ycm_server_use_vim_stdout = 1   " Uncomment these two settings
" let g:ycm_server_log_level = 'debug'  " to debug.

" ---- scrooloose/nerdtree Setup ----
let NERDTreeShowHidden = 1    " Show hidden files
let NERDTreeIgnore=['\.py[co]$', '^__pycache__$', '\.DS_Store', '\.swp$']

" ---- ctrlpvim/ctrlp.vim.git Setup ----
" Use a reasonable matcher function.
let g:ctrlp_match_func = {'match' : 'pymatcher#PyMatch' }
" Normally use a VCS to list files -- except when in an LLVM directory, which
" contains nested Git respositories. In that case, I want to search from all
" files in each of the nested repositories -- but exclude the build directory.
let g:ctrlp_user_command = {
  \ 'types': {
    \ 1: ['LLVMBuild.txt', 'find %s -type f -not -path "*.git/*" -not -path "*build/*"'],
    \ 2: ['.git', 'cd %s && git ls-files'],
    \ 3: ['.hg', 'hg --cwd %s locate -I .'],
    \ },
  \ 'fallback': 'find %s -type f -not -path "*.git/*" -not -path "*build/*"'
  \ }
" Don't change anything about the working path, regardless of which file we
" open in the buffer.
let g:ctrlp_working_path_mode = ''
let g:ctrlp_extensions = ['line']
" Display the window at the bottom (default), order it bottom-to-top
" (default), with a minimum height of 1, maximum of 5, and displaying 5
" results.
let g:ctrlp_match_window = 'bottom,order:btt,min:1,max:5,results:5'

" ---- tpope/vim-fugitive Setup ----
autocmd QuickFixCmdPost *grep* cwindow

" ---- octol/vim-cpp-enhanced-highlight Setup ----
let g:cpp_class_scope_highlight = 1

" ---- Terminal Setup ----
if (&term =~ "xterm") && (&termencoding == "")
  set termencoding=utf-8
endif

" ---- Keybindings Setup ----
map <leader>1 :NERDTreeToggle<CR>  " \1 toggles the nerdtree file tree.
map <leader>2 :TagbarToggle<CR>  " \2 toggles the tag list sidebar.
map <leader>j :NERDTreeFind<CR>  " \j displays the current file in the file
                                 " tree.
" <C-]> opens a tag definition in the current buffer.
map <leader>] :YcmCompleter GoTo<CR>  " \] opens the declaration or
                                      " definition in the current buffer.
map <leader>[ :YcmCompleter GetType<CR>  " \[ echoes the type of the text under
                                         " the cursor.
map <leader>' :YcmCompleter GetParent<CR>  " \' echoes the parent context of the
                                           " text under the cursor (i.e.: the
                                           " name of the method it's in).

let g:clang_format_path = "/Users/modocache/Source/llvm/git/system/install/bin/clang-format"
map <leader>f :pyf ~/Source/llvm/git/system/llvm/tools/clang/tools/clang-format/clang-format.py<CR>

" ---- General Setup ----
set encoding=utf-8  " Default encoding should always be UTF-8.
set mouse=a  " Enable the mouse in all modes.
set t_Co=256  " Use 256 colors.
set background=light  " Use a light theme.
colorscheme PaperColor  " This color scheme is included in
                    " flazz/vim-colorschemes.
set hlsearch  " Highlight searches.
              " FIXME: Use the Gary Bernhardt trick to remove highlight after
              "        hitting the enter key.
set incsearch  " Highlight matches incrementally as pattern is typed.
highlight Search cterm=NONE ctermfg=grey ctermbg=blue
highlight IncSearch cterm=NONE ctermfg=grey ctermbg=blue
set nowrap  " Never wrap lines.
set number  " Display line numbers.
syntax on  " Enable syntax highlighting.
set nostartofline  " Don't reset cursor to the start of the line when moving.
set cursorline  " Highlight the current line.
set cursorcolumn  " Highlight the current column.
set ruler  " Show the cursor position.
set colorcolumn=81,121  " Display columns just after 80 and 120 characters.
set laststatus=2  " Two status lines; the second one displays a file name.
set esckeys  " Allow cursor keys in insert mode.
set backspace=indent,eol,start  " Allow backspace in insert mode.
set ignorecase  " Ignore case when searching.
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
set backupdir=~/.vim/backups  " Place backups, swap files, and undo
set directory=~/.vim/swaps    " history at a specific location.
if exists("&undodir")
  set undodir=~/.vim/undo
endif

" ---- Window Size Setup ----
set winwidth=84      " Set a normal width of 84 columns...
set winminwidth=15   " ...with a minimum of 15 columns.
set winheight=5     " We have to have a winheight bigger than we want to set
set winminheight=5  " winminheight. But if we set winheight to be huge before
set winheight=999    " winminheight, the winminheight set will fail.

" ---- Markdown Setup ----
au BufRead,BufNewFile *.md set filetype=markdown  " Markdown doesnt seem to be
                                                  " the default for .md files,
                                                  " so explicitly set it.

" ---- Python Setup ----
au Filetype python setl et ts=4 sw=4

