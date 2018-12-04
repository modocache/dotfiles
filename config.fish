# Disable fish greeting.
set fish_greeting


# Configure fish shell colors.
set -g fish_color_autosuggestion 7596E4
set -g fish_color_command 164CC9
set -g fish_color_comment 007B7B
set -g fish_color_cwd blue
set -g fish_color_cwd_root red
set -g fish_color_end 02BDBD
set -g fish_color_error 9177E5
set -g fish_color_escape bryellow\x1e\x2d\x2dbold
set -g fish_color_history_current \x2d\x2dbold
set -g fish_color_host normal
set -g fish_color_match \x2d\x2dbackground\x3dbrblue
set -g fish_color_normal normal
set -g fish_color_operator bryellow
set -g fish_color_param 4319CC
set -g fish_color_quote 4C3499
set -g fish_color_redirection 248E8E
set -g fish_color_search_match bryellow\x1e\x2d\x2dbackground\x3dbrblack
set -g fish_color_selection white\x1e\x2d\x2dbold\x1e\x2d\x2dbackground\x3dbrblack
set -g fish_color_status red
set -g fish_color_user brgreen
set -g fish_color_valid_path
set -g fish_pager_color_completion \x1d
set -g fish_pager_color_description B3A06D\x1eyellow
set -g fish_pager_color_prefix white\x1e\x2d\x2dbold\x1e\x2d\x2dunderline
set -g fish_pager_color_progress brwhite\x1e\x2d\x2dbackground\x3dcyan

# Used by the VCS prompts below.
set -g vcs_modified_and_untracked_color 0896ce


function prompt_hg -d "Display the current Mercurial status"
  # TODO
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
      set_color green
    else
      # There must be staged or unstaged changes, or untracked files.
      if test -z "$staged"
        # Nothing staged.
        if test -z "$unstaged"
          # Nothing staged or unstaged, there must be untracked files.
          set_color red
        else
          # No staged, only unstaged changes.
          set_color yellow
        end
      else
        # Staged changes.
        if test -z "$unstaged"
          # Only staged changes, no unstaged.
          set_color yellow
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
      set_color green
    else
      # There are some tracked or untracked changes.
      if test -z "$modified"
        # There are no tracked changes.
        if test -z "$untracked"
          # There are no tracked or untracked changes, and yet 'svn status'
          # had output? Something is wrong.
          set_color red
        else
          # There are no tracked changes, but there are untracked changes.
          set_color red
        end
      else
        # There are tracked changes.
        if test -z "$untracked"
          # Only tracked changes, no untracked ones.
          set_color yellow
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
    echo ")"
  end
end


function fish_prompt
  if [ $status -ne 0 ]
    set_color red
    echo -n "× "
  end

  set_color b2ffb2
  echo -n -s (date "+%m-%d-%y %H:%M:%S ")

  set_color $fish_color_cwd
  echo -n -s (prompt_pwd)

  type -q hg;  and prompt_hg
  type -q git; and prompt_git
  type -q svn; and prompt_svn

  set_color $fish_color_command
  echo " > "
end


# Set up an alias for using upstream Arcanist. I can't use its 'arc' directly
# because that conflicts with the 'arc' executable that's vended to Facebook
# engineers.
alias llvm-arc "~/local/Source/llvm/utils/arcanist/bin/arc"

# Prepend my locally built Vim directory to my PATH.
set -U fish_user_paths ~/local/Source/modocache/vim/install/bin $fish_user_paths
# Prepend Homebrew 'brew' executable to my PATH.
set -U fish_user_paths ~/local/.brew/bin $fish_user_paths

# Append my locally built LLVM bin directory to my PATH. This keeps
# 'which clang' pointing to macOS's '/usr/bin/clang', but extra tools like
# 'which clang-format' point to the one in this directory.
set PATH $PATH ~/local/Source/llvm/git/system/install/bin
