" Vim
" ===
"
" Vim is a text editor. It's useful because:
"
" 1. Its graphical interface is text based, so it can run in a terminal. This
"    means I can have a comfortable text editing experience, whether on my own
"    host machine, or when editing on a remote machine via SSH.
" 2. It can be installed on many different operating systems, such as Linux or
"    macOS.
" 3. It can be manipulated entirely via the keyboard.
" 4. It's heavily customizable.
"
" Installation quickstart
" -----------------------
"
" This configuration expects certain directories and programs to exist on the
" host machine. These are explained in detail below, but to get up and running
" quickly, just go ahead and do the following:
"
" 1. `ln -s (pwd)/.vimrc  ~/.vimrc`
" 2. `mkdir -p ~/.vim/backups ~/.vim/swaps ~/.vim/undo`
" 3. Clone Vundle, using the following command:
"
"      git clone https://github.com/VundleVim/Vundle.vim.git \
"            ~/.vim/bundle/Vundle.vim
"
" 4. Open Vim and run :PluginInstall.
" 5. Some plugins and keybindings require additional setup:
"    1. Valloric/YouCompleteMe:
"       Run the following commands:
"
"         cd ~/.vim/bundle/YouCompleteMe
"         python3 ./install.py --clang-completer --rust-completer
"
"       To enable completion for any project, add a symlink to
"       'compile_commands.json' from the root directory within which you're
"       opening Vim. For llvm-project, that would mean:
"
"         cd llvm-project
"         ln -s build/compile_commands.json compile_commands.json
"
"    2. clang-format:
"       `clang-format` must exist on your PATH (i.e. `which clang-format`
"       must return the path to a `clang-format` executable), and the
"       environment variable `$CLANG_FORMAT_PY` must be set.
"
"       If using fish shell, the following lines will accomplish this:
"
"         # Add an LLVM build directory (with `clang-format` built) to PATH:
"         fish_add_path $HOME/path/to/llvm-project/build/bin
"         # Export the $CLANG_FORMAT_PY environment variable:
"         set -Ux CLANG_FORMAT_PY \
"           "$HOME/path/to/llvm-project/" \
"           "clang/tools/clang-format/clang-format.py"
"
" 6. Configure Vim settings specific to the current host machine by creating a
"    file at `~/.vim/local.vimrc`.
" 7. If you wish, you may build and install Vim from source. To do so:
"
"      git clone https://github.com/vim/vim.git
"      cd vim
"      vim Makefile       # Toggle options to '--enable-python3interp', etc.
"      make
"      sudo make install  # To uninstall, 'sudo make uninstall'

" Core configuration: commands and setting options
" ------------------------------------------------
"
" This configuration file makes use of plugins, which can be configured using
" global variables (more on that later). But Vim itself is configured using
" options:
" - Most options may be set using the `set` command.
" - You can execute any command in Vim by pressing `:`, then the name of the
"   command.
" - The `help <name>` command opens a buffer to explain most everything in Vim.
" - For example, `help set` explains the `set` command, including the fact
"   that `set all` can be used to print all available options.
" - When manual entries are ambiguous, special syntax can be used to
"   disambiguate. For example, to display help for the Vim option `backspace`,
"   use single quotes: `help 'backspace'`. A list of all the syntaxes can be
"   found with `help notation`.
" - Many option names come in two flavors: `<name>` which enables the option,
"   and `no<name>` which disables it.
"
" By default, the `help` command splits a window horizontally. The `vertical`
" command can be used to run any command, and if that command splits the window,
" it will be split vertically instead. So, `vertical help` opens the Vim
" reference manual in a vertical split instead.
"
" My preferred options are as follows:
" - Normally Vim doesn't respond to mouse events. This option enables the use
"   of the mouse in all of Vim's various "modes" (nomal, visual, insert,
"   etc.).
set mouse=a
" - When moving the cursor up and down, keep it at its original column, or
"   if not possible, at the last character in the line.
set nostartofline
" - `backspace` changes how the `<BS>` and `<Del>` keys, and the `Ctrl-w` and
"   `Ctrl-u` key combinations, work in insert mode.
"   - `eol` allows for backspacing past line breaks.
"   - `indent` allows for backspacing past any automatic indentation that Vim
"     inserts when entering insert mode.
"   - `start` allows for backspacing past where the cursor began when insert
"     mode was entered, but `Ctrl-w` (which normally deletes a word) stops once
"     at the point where insert mode was entered.
set backspace=eol,indent,start

" - Once a search term has been entered, continue to highlight all matches,
"   until either a new search term is entered, or the `nohlsearch` command is
"   executed.
set hlsearch
" - When typing a search command, highlight matches for the pattern as entered
"   so far.
set incsearch
" - Don't wrap around the end of buffer content when searching.
set nowrapscan
" - Ignore case when searching, unless the search term is prefixed with `\C`.
set ignorecase

" - Display absolute line numbers to the left of each line in the editor.
"   (Note that relative line numbers can be displayed with `relativenumber`.)
set number
" - Do not wrap long lines.
set nowrap
" - By default, unless overridden for a specific file type,  break lines at
"   80 characters.
set textwidth=80

" - Enable syntax highlighting.
syntax enable
" - Highlight the line with the cursor.
set cursorline
" - Highlight the column with the cursor.
set cursorcolumn
" - Disable cursor line and column highlighting when the cursor leaves a
"   window, and re-enable it when the cursor enters a window.
"   - This is possible using Vim's `autocmd`, which allows users to specify
"     commands to be executed when certain "autocommand events" occur.
"     The syntax is `autocmd {event} {file-pattern} {command}`.
"   - `autocmd` can be grouped, using the `augroup` command. Groups of
"     `autocmd` can be conveniently executed or removed.
"   - `autocmd!` deletes all previously defined autocommands in the current
"     group. When a `.vimrc` is sourced twice, each autocommand adds to a list
"     of commands, regardless of whether they're already present. So it's a
"     good idea to clear them out.
augroup cursor_active_window_only
  autocmd!
  autocmd WinLeave * set nocursorline nocursorcolumn
  autocmd WinEnter * set cursorline cursorcolumn
augroup end
" - Display guiding columns in each window, just after the specified
"   `textwidth`.
set colorcolumn=+1

" - Display the line and column of the cursor in the window status line.
set ruler
" - This setting takes an enum value that controls whether the window status
"   line is displayed; `2` indicates it should always be displayed.
set laststatus=2

" - Disable error "bells" (either a sound or a screen flash) in all cases,
"   including things like when I hit <Esc> in normal mode. I disable audio
"   and visual error bells in my terminal application settings as well.
set belloff=all

" There are also several options that typically appear in others' vimrc, but
" that I don't include here:
" - `set nocompatible`: Vim automatically sets `nocompatible` if it finds a
"   `.vimrc` file at startup, so there's no need to explicitly set this.
" - `set encoding=utf-8`: Vim automatically sets this to the value of the
"   `$LANG` environment variable, which is en_US.UTF-8 on most systems I care
"   about.
" - `scriptencoding utf-8`: This performs encoding conversion when a script's
"   encoding differs from Vim's `encoding` value. Conversion can fail silently
"   for many reasons, and I don't care to enable it.
" - `termencoding=utf-8`:
"set t_Co=256  " Use 256 colors.
" - Function and cursor keys send input sequences that begin with `Escape`,
"   which is also a Vim control character. So, by default... this is redundant
"   with nocompatible, since it's off by default in Vim mode (but on by default
"   in vi mode).
" set esckeys  " Allow cursor keys in insert mode.

" ---- Terminal Setup ----
"if (&term =~ "xterm") && (&termencoding == "")
"  set termencoding=utf-8
"endif
" ---- General Setup ----
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
set winheight=5      " We have to have a winheight bigger than we want to set
set winminheight=5   " winminheight. But if we set winheight to be huge before
set winheight=999    " winminheight, the winminheight set will fail.
" ---- Automatic Commands ----
" Set the background based on the current system time.
function! UpdateBackground()
  if strftime("%H") >= 7 && strftime("%H") < 16
    set background=light
  else
    set background=dark
  endif
endfunction
" Update the background as soon as Vim starts.
call UpdateBackground()
augroup vimrc
  " Delete all previously defined au[tocmd] in this aug[roup].
  autocmd!
  " Markdown doesnt seem to be the default for .md files, so explicitly set it.
  autocmd BufRead,BufNewFile *.md set filetype=markdown
  " When any of these events occur, in any file `*`, call the function to
  " update the background to either light or dark based on the current time.
  autocmd CursorHold,CursorHoldI,WinEnter,WinLeave,FocusLost,FocusGained,
          \VimResized,ShellCmdPost * call UpdateBackground()
augroup end

" ---- Vundle Setup ----
filetype off  " Required for Vundle. This is re-enabled further down.

set shell=/bin/bash  " Vundle's commands, such as :PluginInstall, do not work
                     " in fish shell. See:
                     " https://github.com/VundleVim/Vundle.vim/issues/690
set rtp+=~/.vim/bundle/Vundle.vim  " Include Vundle in the runtime path.
call vundle#begin('~/.vim/bundle')  " Initialize Vundle.

Plugin 'gmarik/Vundle.vim'  " This plugin is required by Vundle itself.
Plugin 'ctrlpvim/ctrlp.vim.git'  " Fuzzy finder.
Plugin 'dag/vim-fish' " Syntax highlighting and more for `.fish` files.
Plugin 'FelikZ/ctrlp-py-matcher'  " The default matcher in ctrlp.vim is
                                  " god awful. 'opt.cpp' doesn't find the file
                                  " 'tools/opt/opt.cpp'...?! Replace it with
                                  " something reasonable.
Plugin 'scrooloose/nerdtree'  " Tree explorer.
Plugin 'tpope/vim-fugitive'  " Git integration.
Plugin 'tomtom/tcomment_vim'  " Comment out blocks of code.
Plugin 'majutsushi/tagbar'  " Displays tags in a file in the sidebar.
Plugin 'NLKNguyen/papercolor-theme'  " The color scheme I prefer. Supports both
                                     " light and dark backgrounds.
Plugin 'vim-scripts/TagHighlight'  " Enhanced syntax highlighting by parsing
                                   " ctags.
Plugin 'Valloric/YouCompleteMe'  " Autocompletion for many languages, most
                                 " notably C/C++/Objective-C via libclang.
Plugin 'rust-lang/rust.vim' " Rust file detection and syntax highlighting.
" Syntax highlighting for LLVM *.ll and tablegen *.td files.
Plugin 'llvm/llvm-project', { 'rtp' : 'llvm/utils/vim' }
" Syntax highlighting for MLIR *.mlir files.
" FIXME: I don't know of a better way to trick Vundle into looking at both
"        'llvm-project/llvm/utils/vim' *and* 'llvm-project/mlir/utils/vim',
"        which is why I download two copies of llvm-project and name this one
"        'mlir'.
" FIXME: I probably don't need Vundle at all, I can just add the MLIR path to
"        rtp/runtimepath.
Plugin 'modocache/llvm-project', {'name': 'mlir', 'rtp': 'mlir/utils/vim'}

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
let g:ycm_confirm_extra_conf = 0  " I make use of '.ycm_extra_conf.py' and I
                                  " prefer not to confirm each time I load it.
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
" FIXME: ctrlp makes a cache at `$USER/.cache/ctrlp`, change this via a user
" setting.
let g:ctrlp_match_func = {'match' : 'pymatcher#PyMatch' }
" Normally use a VCS to list files -- except when in an llvm-project directory
" (which normally contains a directory 'mlir'), which may contain nested Git
" respositories which I would also like included in searches. For that case, use
" 'find' to list the files in each of the nested repositories, but exclude the
" '.git' and 'build' directories.
" FIXME: Update this comment.
let g:ctrlp_user_command = {
  \ 'types': {
    \ 1: ['third-party', 'find %s -type f -not -path "*.git/*" -not -path "*build/*" -not -path "*.derived/*"'],
    \ 2: ['.git', 'cd %s && git ls-files'],
    \ 3: ['.hg', 'hg --cwd %s locate -I .'],
    \ },
  \ 'fallback': 'find %s -type f -not -path "*.git/*" -not -path "*build/*" -not -path "*.derived/*"'
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
map <leader>} :LspDefinition<CR> " \} opens the definition when using LSP.
map <leader>{ :LspHover<CR> " \{ displays information about the item under
                            " the cursor.

" \f uses clang-format on the line or selection.
map <leader>f :py3f $CLANG_FORMAT_PY<CR>

" Clang format on close
" https://vi.stackexchange.com/questions/21102/how-to-clang-format-the-current-buffer-on-save
function FormatBuffer()
  if &modified && !empty(findfile('.clang-format', expand('%:p:h') . ';'))
    let cursor_pos = getpos('.')
    silent :%!clang-format
    call setpos('.', cursor_pos)
  endif
endfunction
augroup clang_format
  autocmd!
  autocmd BufWritePre *.h,*.hpp,*.c,*.cpp :call FormatBuffer()
augroup end

" \/ turns off highlighting for matches of the last search pattern.
" (Note that `nohlsearch` is not the same thing as `set nohlsearch`, which
" would disable the option for all searches.)
map <leader>/ :nohlsearch<CR>

runtime local.vimrc

colorscheme PaperColor  " Enable the PaperColor scheme.
"
" FIXME: Evaluate clangd, and update or remove this comment:
"       (Last time I evaluated it, on April 8 2020, the '--clangd-completer'
"       was slow to the point of being unusable for llvm-project.)
" FIXME: What do these do?
"highlight Search cterm=NONE ctermfg=grey ctermbg=blue
"highlight IncSearch cterm=NONE ctermfg=grey ctermbg=blue


" vim: set textwidth=80 tabstop=8 softtabstop=2 shiftwidth=2 expandtab nowrap:
