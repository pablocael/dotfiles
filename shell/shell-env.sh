export EDITOR='nvim'
export VISUAL='nvim'

# set vim mode
set -o vi

# aliases
alias k='kubectl'
alias kx='kubectx'
alias kn='kubens'
alias vim='nvim'
alias ipython='python3 -m IPython'

[ -f ~/.fzf.bash ] && source ~/.fzf.bash

export PYENV_ROOT="$HOME/.pyenv"
command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

export PYTHON_SITE_BASE=`python3 -c "from distutils.sysconfig import get_python_lib; print(get_python_lib())"`

if [ -f `which powerline-daemon` ]; then
  powerline-daemon -q
  POWERLINE_BASH_CONTINUATION=1
  POWERLINE_BASH_SELECT=1
  . /usr/share/powerline/bash/powerline.sh
fi

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# Avoid duplicates
HISTCONTROL=ignoredups:erasedups
# When the shell exits, append to the history file instead of overwriting it
shopt -s histappend

# After each command, append to the history file and reread it
PROMPT_COMMAND="${PROMPT_COMMAND:+$PROMPT_COMMAND$'\n'}history -a; history -c; history -r"
export PATH=$PATH:$HOME/scripts/
