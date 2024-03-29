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
"           (string join / $HOME path to llvm-project \
"            clang tools clang-format clang-format.py)
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
"   that `set all` can be used to print all available options, and that
"   `set mouse?` can be used to print the value of the `mouse` option. (What's
"   more, `verbose set mouse?` will tell you where this option was last set.)
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
" (By the way, speaking of split windows: use `help wincmd` to learn more about
" how to move windows around. For example, `Ctrl-w x` swaps the current window
" with the next one. So, if you opened `vertical help wincmd` and found the help
" window to the left of your current one, you can swap their positions with
" `Ctrl-w x`. Alternatively, you could have run `vert rightbelow help wincmd`.)
"
" My preferred options are as follows:
" - Normally Vim doesn't respond to mouse events. This option enables the use
"   of the mouse in all of Vim's various "modes" (nomal, visual, insert,
"   etc.).
set mouse=a
" - Disable error "bells" (either a sound or a screen flash) in all cases,
"   including things like when I hit <Esc> in normal mode. I disable audio
"   and visual error bells in my terminal application settings as well.
set belloff=all
" - Vim displays messages in response to various events. Many of these can be
"   configured with flags passed to the `shortmess` option:
"   - `I`: Don't display an intro message when starting Vim.
set shortmess=I

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
" - Specify exactly how Vim formats text, according to the character codes
"   explained in `help fo-table`. By default, Vim uses `tcq`, and `croql` for
"   C/C++ files. I use the same for all files:
"   - `c`: Auto-wrap comments using `textwidth`, inserting the current comment
"          leader automatically. Here, "current comment leader" means "the
"          comment opening syntax when in a comment, or nothing if not in a
"          comment."
"   - `l`: Long lines are not broken in insert mode.
"   - `o`: Automatically insert the current comment leader after hitting 'o' or
"          'O' in normal mode.
"   - `q`: Type `gq` to format a comment.
"   - `r`: Automatically insert the current comment leader when hitting
"          `<Enter>` in insert mode.
set formatoptions=cloqr

" - Enable syntax highlighting.
syntax enable
" - Highlight the line with the cursor.
set cursorline
" - Highlight the column with the cursor.
set cursorcolumn
" - Display guiding columns in each window, just after the specified
"   `textwidth`.
set colorcolumn=+1

" - Display the line and column of the cursor in the window status line.
set ruler
" - This setting takes an enum value that controls whether the window status
"   line is displayed; `2` indicates it should always be displayed.
set laststatus=2

" - In `list` mode, Vim displays special characters that represent things like
"   the end of a line or a tab. `listchars` can be used to configure what's
"   represented by which charactets.
set list
" - `listchars` is a comma-separated sequence of "invisible concept,"
"   colon, and then the character to display to represent that invisible
"   concept.
"   - `eol`: Used to represent the end of a line.
"   - `extends`: Character to show in the last column of a line that extends
"                past the right edge of the screen (when `nowrap` is set).
"   - `nbsp`: Used for non-breakable space characters, like `U+202F`.
"   - `precedes`: Shown in the first column of a line that extends past the left
"                 edge of the screen (when `nowrap` is set).
"   - `tab`: Used for tabs. The first character is always displayed, then the
"            second character (here a space, which must be escaped) is inserted
"            as many times as fits within a tab.
"   - `trail`: Used for trailing spaces.
set listchars=eol:¬,extends:>,nbsp:▝,precedes:<,tab:▸\ ,trail:▝

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
set wildmenu  " Enhance command-line completion.
set ttyfast  " Use advanced tty features for smoother drawing.
set expandtab  " Use spaces when hitting tab.
set shiftwidth=2  " By default, use two spaces to indent.
set tabstop=2  " By default, tabs are represented by two spaces.
set backupdir=~/.vim/backups  " Place backups, swap files, and undo
set directory=~/.vim/swaps    " history at a specific location.
if exists("&undodir")
  set undodir=~/.vim/undo
endif
" ---- Window Size Setup ----
set winwidth=85      " Set a normal width of 85 columns...
set winminwidth=15   " ...with a minimum of 15 columns.
set winheight=5      " We have to have a winheight bigger than we want to set
set winminheight=5   " winminheight. But if we set winheight to be huge before
set winheight=999    " winminheight, the winminheight set will fail.
" ---- Automatic Commands ----
" Set the background based on the current system time.
function! UpdateBackground()
  if strftime("%H") >= 7 && strftime("%H") < 17
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

" Valloric/YouCompleteMe
" ----------------------
"
" - YouCompleteMe will automatically compile and produce diagnostics for source
"   files opened in Vim. Placing the cursor on a line that has a diagnostic will
"   display the diagnostic in the Vim status bar. You can use <leader>d on a
"   line with a diagnostic in order to expand the Vim status bar to display the
"   entire diagnostic message.
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

" ctrlpvim/ctrlp.vim.git & FelikZ/ctrlp-py-matcher
" --------------------------------------------------
"
" CtrlP is a fuzzy file finder that can be activated using `<C-p>`. It brings up
" a small window and, as I type, presents files that I can open using `<Enter>`.
" (ctrlp-py-matcher is a file matcher function that can be plugged into CtrlP.)
"
" - Alternatively, `<C-v>` opens the file under the cursor in a vertical split,
"   and `<C-t>` opens it in a new tab.
" - Type `:25` after the file name in order to jump to line 25 once it's opened.
" - CtrlP utilizes a cache of the files it has found. It can be refreshed via
"   the `:CtrlPClearCache` command, or by pressing `<F5>` within the CtrlP
"   finder window. (Note that on some Apple keyboards, you may need to hold down
"   the `Fn` key while pressing `F5` in order to actually send `<F5>`.)
" - The built-in CtrlP matching algorithm exhibits behavior I don't relish. For
"   example, searching for "executionengine.cpp" inside of the llvm/llvm-project
"   repository does not display "llvm/lib/ExecutionEngine/ExecutionEngine.cpp"
"   or "mlir/lib/ExecutionEngine/ExecutionEngine.cpp" within the top 5 results,
"   which simply seems incorrect to me. So, instead, we use the matcher function
"   provided by the FelikZ/ctrlp-py-matcher project, which provides results more
"   in line with my expectations.
let g:ctrlp_match_func = {'match' : 'pymatcher#PyMatch' }
" - CtrlP allows for a custom command to be used to determine the list of all
"   files in the project, so I use version control systems where possible: `git`
"   within Git repositories (with recursion into any submodules, since many
"   projects I work on include LLVM and other projects as submodules), and `hg`
"   within Mercirual repositories. Otherwise, fall back to the `find` command.
let g:ctrlp_user_command = {
  \ 'types': {
    \ 1: ['.git', 'git -C %s ls-files --recurse-submodules'],
    \ 2: ['.hg', 'hg --cwd %s locate -I .'],
    \ },
  \ 'fallback': 'find %s -type f -not -path "*.git/*"'
  \ }
" - CtrlP sets its local working directory based on a complex series of rules
"   (such as recursively searching parent directories for a `.git` directory,
"   etc.), and I find these confusing and not worth learning about. So, I
"   disable this behavior.
let g:ctrlp_working_path_mode = ''
" - By default, CtrlP places its cache at `$HOME/.cache/ctrlp`. However, I
"   prefer to keep my `$HOME` directory uncluttered, and so I nest the cache
"   within the `$HOME/.vim` directory.
let g:ctrlp_cache_dir = $HOME.'/.vim/cache/ctrlp'
" - By default, CtrlP clears its cache when Vim exits. However, rebuilding the
"   cache can take a few seconds for large projects such as llvm/llvm-project,
"   which slows me down when I want to jump into coding. So, I disable automatic
"   cache clearing on exit, and instead rely on manually rebuilding the cache
"   (via the `:CtrlPClearCache` command, or `<F5>` within a CtrlP window) to
"   pick up new files and to exclude old ones that no longer exist.
let g:ctrlp_clear_cache_on_exit = 0
" - CtrlP allows for a great deal of customization of how its finder window is
"   displayed:
"   - `max`: The maximum height of the window. This is `10`, but I prefer
"            something more compact.
let g:ctrlp_match_window = 'max:5'

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

" Define a function that runs `clang-format` on the difference between the
" entire buffer and what's on disk, so that Vim can call it before writing a
" buffer (`BufWritePre`). This function is adapted from the LLVM project's
" `clang-format` documentation:
" https://clang.llvm.org/docs/ClangFormat.html#vim-integration
function ClangFormatBuffer()
  " Since this function is called whenever a buffer is about to be written for a
  " C/C++ file, we really don't want it to fail, since that would make it a huge
  " pain to edit those files. So, check that `$CLANG_FORMAT_PY` points to a
  " valid file using `filereadable`, and bail if that environment variable
  " hasn't set that up yet.
  "
  " Also, this behavior is fairly intrusive, so only perform the formatting when
  " modifying paths in a project that has a `.clang-format` file. To do so, use:
  " - `expand`, which expands a string with special keywords. Here, `%` refers
  "   to the current file, `:p` is a modifier that expands that file to its full
  "   path, and `:h` removes the last component of the path (the file name). As
  "   a result, this becomes a string representing the path to the directory
  "   that contains the buffer being written.
  " - `findfile`, which searches for a file with the given name, starting from
  "   the given directory. If its string argument for the directory to start
  "   from ends with a `;`, then it searches recursively upward. Here, we use
  "   the `.` operator to concatenate the result from `expand` with the
  "   character `;`.
  if !filereadable($CLANG_FORMAT_PY) ||
        \ empty(findfile('.clang-format', expand('%:p:h') . ';'))
    return
  endif

  " Assuming we got this far, invoke `clang-format.py`. When `l:formatdiff=1` is
  " set, it is run on all files that differ between the buffer and what's on
  " disk (if there is a disk representation).
  let l:formatdiff = 1
  py3f $CLANG_FORMAT_PY
endfunction
augroup clang_format
  autocmd!
  autocmd BufWritePre *.h,*.hpp,*.c,*.cc,*.cpp :call ClangFormatBuffer()
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
