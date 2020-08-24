# If you come from bash you might have to change your $PATH.
setopt aliases
export GOPATH=$HOME/go
export PATH=$HOME/bin:/usr/local/bin:$GOPATH/bin:/usr/local/opt/make/libexec/gnubin:$PATH
export ZSH="/root/.oh-my-zsh"
export HISTFILE="/root/.apollo/.history"
export DRACULA_ARROW_ICON="🚀"

ZSH_THEME="dracula"
plugins=(
	git
	zsh-autosuggestions
	zsh-completions
  zsh-syntax-highlighting
  fzf
)

# zsh-completions
autoload -U compinit && compinit

source $ZSH/oh-my-zsh.sh

source $ZSH/plugins/fzf-tab-completion/zsh/fzf-zsh-completion.sh
source $ZSH/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
#source /apollo/apollo.plugin.zsh

# forgit - https://github.com/wfxr/forgit
[ -f ~/.forgit/forgit.plugin.zsh ] && source ~/.forgit/forgit.plugin.zsh

# Prompt
if [ $APOLLO_DEVELOPMENT -eq 1 ];
then
  export PS1="[DEV] ${PS1}"
fi

# ALIASES

# Generic commands
alias reload="source ~/.zshrc"
alias ls='ls --color=auto'
alias grep='grep --color'
alias zshrc="nano ~/.zshrc"
alias -g Z='| fzf'

# MOTD
#cat /etc/motd