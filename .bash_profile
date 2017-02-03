# .bashrc
# Brian Gesiak <modocache@gmail.com>
# vim: set fmr={{{,}}} fdm=marker :

# Ensure interactive mode.
if [[ $- != *i* ]] ; then
  return
fi

# Enable extended pattern matching.
shopt -s extglob
# Save all lines of multi-line commands in history.
shopt -s cmdhist
# Append history, don't overwrite it.
shopt -s histappend

# Unset all locales, and use UTF-8.
eval unset ${!LC_*} LANG
export LANG=en_US.UTF-8

# Disable core dumps.
ulimit -c 0

# Enable colors.
export CLICOLOR=yes

# Store the timestamps of each command in history.
export HISTTIMEFORMAT='%F %T '
# Don't store duplicate commands in history.
export HISTCONTROL=erasedups

# Save a few keystrokes, show hidden files with just 'ls'.
alias ls='ls -lAF'
# A convenient command to reload the .bash_profile.
alias bashreload='source ~/.bash_profile'

_ps_retval_colour_f()
{
  if [[ ${1} -eq 0 ]] ; then
    echo -e "\033[01;34m"
  else
    echo -e "\033[01;31m"
  fi

  return ${1}
}

export PS1='\[\033[01;32m\]\u@\h \[\033[01;34m\]\w \[$(_ps_retval_colour_f $?)\]$ \[\033[00;00m\]'

