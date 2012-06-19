# Vim Configurations

Just my Vim config.

## A Note on Vim

If you're using the default Vim installed on OS X, you'll
notice it's not compiled with Ruby/Python support. To
install a fresh version, fetch the source and build your
own.

    $ hg clone https://vim.googlecode.com/hg/ vim
    $ cd vim
    $ hg pull
    $ hg update
    $ rmv use system  # Make sure to make using system Ruby if using RVM
    $ ./configure --prefix=/usr/local --enable-rubyinterp --enable-pythoninterp --with-features=huge
    $ make
    $ ./src/vim --version  # Make sure Ruby and Python support are in the version info
    $ make install

Make sure `/usr/local/bin/` is on your path to open this
freshly installed version when typing `vim` on the command
line.
