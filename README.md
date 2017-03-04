# dotfiles

My preferred configuration files.

## fish

Use `brew install fish` to install [fish](https://fishshell.com).

To make `fish` the default shell, add `/usr/local/bin/fish` to `/etc/shells`,
then run the following command:

```
$ chsh -s `which fish`
```

To set up the prompt I like, symlink it into your `fish` config:

```
$ ln -s \
    `pwd`/external/shellder/fish_prompt.fish \
    ~/.config/fish/config.fish
```

To set up the color scheme I like, run `fish_config` and select `colors > lava`.

## Vim

First, symlink the vimrc:

```
$ ln -s `pwd`/.vimrc ~/.vimrc
```

Then follow the instructions in the `.vimrc` to finish installing the other
components.

