# Use `brew install fish` to install [fish](https://fishshell.com).
#
# To make `fish` the default shell, add `/usr/bin/fish` to `/etc/shells`,
# then run the following command:
#
# ```
# $ chsh -s `which fish`
# ```
#
# To set up the prompt I like, symlink it into your `fish` config:
#
# ```
# $ ln -s `pwd`/config.fish  ~/.config/fish/config.fish
# ```

# Disable fish greeting.
set fish_greeting


# Set color and environment variables for both 'light' and 'dark' modes.
# For example, these functions set the 'COLORFGBG' environment variable,
# which Vim reads in order to automatically set its 'background' property
# to 'light' or 'dark'.
function light_mode -d "Set variables for light backgrounds"
  # '0;15' means dark text on a light background; i.e.: "light mode".
  set -Ux COLORFGBG "0;15"

  set -g fish_color_autosuggestion 878787
  set -g fish_color_command 0F4D73 --bold
  set -g fish_color_comment 878787
  set -g fish_color_cwd 000000
  set -g fish_color_end D70087
  set -g fish_color_error D70000
  set -g fish_color_operator 0087AF
  set -g fish_color_param 0F4D73
  set -g fish_color_quote 4F7704
  set -g fish_color_redirection D75F00

  set -g date_color 878787
  set -g vcs_clean_color 197A0C
  set -g vcs_modified_color CB4D09
  set -g vcs_untracked_color $fish_color_error
  set -g vcs_modified_and_untracked_color 0F4B9F
end

function dark_mode -d "Set variables for dark backgrounds"
  # '15;0' means light text on a dark background; i.e.: "dark mode".
  set -Ux COLORFGBG "15;0"

  set -g fish_color_autosuggestion 5F8787
  set -g fish_color_command AFD700 --bold
  set -g fish_color_comment 6D6D6D
  set -g fish_color_cwd D0D0D0
  set -g fish_color_end AF87D7
  set -g fish_color_error AF005F
  set -g fish_color_operator 5FAFD7
  set -g fish_color_param AFD700
  set -g fish_color_quote D7AF5F
  set -g fish_color_redirection FF5FAF

  set -g date_color 808080
  set -g vcs_clean_color 5FAF00
  set -g vcs_modified_color FFAF00
  set -g vcs_untracked_color $fish_color_error
  set -g vcs_modified_and_untracked_color 0F4B9F
end


function prompt_git -d "Display the current Git status"
  if command git rev-parse --is-inside-work-tree >/dev/null 2>&1
    set -l stat (command git status --porcelain 2>/dev/null)
    set -l staged (command git diff --staged 2>/dev/null)
    set -l unstaged (command git diff 2>/dev/null)
    set -l untracked (command git ls-files . --exclude-standard --others 2>/dev/null)

    # Set the text color based on the dirtiness of the repository.
    if test -z "$stat"
      # Nothing modified.
      set_color $vcs_clean_color
    else
      # There must be staged or unstaged changes, or untracked files.
      if test -z "$staged"
        # Nothing staged.
        if test -z "$unstaged"
          # Nothing staged or unstaged, there must be untracked files.
          set_color $vcs_untracked_color
        else
          # No staged, only unstaged changes.
          set_color $vcs_modified_color
        end
      else
        # Staged changes.
        if test -z "$unstaged"
          # Only staged changes, no unstaged.
          set_color $vcs_modified_color
        else
          # Staged and unstaged changes.
          set_color $vcs_modified_and_untracked_color
        end
      end
    end

    echo -n " ("

    # Always display the revision.
    set -l ref (command git show-ref --head --hash --abbrev 2>/dev/null | head -n1)
    if test -z "$ref"
      set ref "empty"
    end
    echo -n "$ref"

    # Optionally display a symbolic name for the revision.
    set -l sref (command git symbolic-ref --short HEAD 2>/dev/null)
    if test -n "$sref"
      echo -n " $sref"
    end

    # Display a series of characters after the revision indicating the dirtiness
    # of the repository -- for when copy-pasting output from commands run in
    # dirty repositories.
    if test -n "$stat"
      if test -n "$staged"
        echo -n "+"
      end
      if test -n "$unstaged"
        echo -n "*"
      end
      if test -n "$untracked"
        echo -n "?"
      end
    end

    echo -n ")"
  end
end


function prompt_hg -d "Display the current Mercurial status"
  # TODO
end


function prompt_svn -d "Display the current Subversion status"
  set -l ref
  if command svn ls . >/dev/null 2>&1
    set -l info (command svn info 2>/dev/null)

    # Grab the current revision.
    set -l rev (echo $info | awk -F\  '// { \
      for (i = 0; i <= NF; i++) { \
        if ($i == "Revision:") { print $(i + 1); break; } \
      }
    }')

    # Grab the current branch.
    set -l url (echo $info | awk -F\  '// { \
      for (i = 0; i <= NF; i++) { \
        if ($i == "URL:") { print $(i + 1); break; } \
      }
    }')
    set -l branch (echo $url | awk -F/ '// {
      for (i = 0; i <= NF; i++) { \
        if ($i == "branches" || $i == "tags") { print $(i + 1); break; };
        if ($i == "trunk") { print($i); break; }
      } \
    }')

    # Grab repository status.
    set -l stat (command svn status)
    set -l modified
    set -l untracked
    if test -n "$stat"
      set modified (echo $stat | awk -F\  '// {
        for (i = 0; i <= NF; i++) { \
          if ($i == "M") { print($i); break; }
        } \
      }')
      set untracked (echo $stat | awk -F\  '// {
        for (i = 0; i <= NF; i++) { \
          if ($i == "?") { print($i); break; }
        } \
      }')
    end

    # Set an appropriate color based on status.
    if test -z "$stat"
      # No tracked or untracked changes.
      set_color $vcs_clean_color
    else
      # There are some tracked or untracked changes.
      if test -z "$modified"
        # There are no tracked changes.
        if test -z "$untracked"
          # There are no tracked or untracked changes, and yet 'svn status'
          # had output? Something is wrong.
          set_color $fish_color_error
        else
          # There are no tracked changes, but there are untracked changes.
          set_color $vcs_untracked_color
        end
      else
        # There are tracked changes.
        if test -z "$untracked"
          # Only tracked changes, no untracked ones.
          set_color $vcs_modified_color
        else
          # There are tracked and untracked changes.
          set_color $vcs_modified_and_untracked_color
        end
      end
    end

    # Print the revision and branch.
    echo -n " (r$rev $branch"

    # Print markers based on the repository's status.
    if test -n "$stat"
      # There are some tracked or untracked changes.
      if test -z "$modified"
        # There are no tracked changes.
        if test -z "$untracked"
          # There are no tracked or untracked changes, and yet 'svn status'
          # had output? Something is wrong.
          echo -n "!"
        else
          # There are no tracked changes, but there are untracked changes.
          echo -n "?"
        end
      else
        # There are tracked changes.
        if test -z "$untracked"
          # Only tracked changes, no untracked ones.
          echo -n "*"
        else
          # There are tracked and untracked changes.
          echo -n "*?"
        end
      end
    end

    # Print the closing paren.
    echo -n ")"
  end
end


function fish_prompt
  # Preserve status before setting light or dark mode.
  set -l code $status

  # Use 'light' or 'dark' mode settings based on the current time.
  set -l hour (command date "+%H")
  if test $hour -ge 7; and test $hour -lt 16
    light_mode
  else
    dark_mode
  end

  # Print an 'x' if the previous status was nonzero.
  if test $code -ne 0
    set_color $fish_color_error
    echo -n "× "
  end

  set_color $date_color
  echo -n -s (date "+%m-%d-%y %H:%M:%S ")

  set_color $fish_color_cwd
  echo -n -s (prompt_pwd)

  type -q hg;  and prompt_hg
  type -q git; and prompt_git
  type -q svn; and prompt_svn

  set_color $fish_color_param
  echo " > "
end


# Set environment variables.
set -Ux EDITOR (which vim)


# Load host-specific fish configuration file.
source ~/.config/fish/config.local.fish
