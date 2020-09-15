# If you come from bash you might have to change your $PATH.
setopt aliases
export GOPATH=$HOME/go
export PATH=$HOME/bin:/usr/local/bin:$GOPATH/bin:/usr/local/opt/make/libexec/gnubin:$PATH
export ZSH="/root/.oh-my-zsh"
export HISTFILE="/root/.apollo/.history"

ZSH_THEME="alanpeabody"
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

eval "$(starship init zsh)"
source /apollo/apollo.plugin.zsh

# Generic commands
alias reload="source ~/.zshrc"
alias ls='lsd'
alias grep='grep --color'
alias zshrc="nano ~/.zshrc"
alias -g Z='| fzf'
alias less="bat"

apollo::echo "Welcome to ${bold}apollo${normal} ($APOLLO_VERSION). Type ${bold}apollo --help${normal} to see your options"
apollo::echo "If you need support, please visit ${bold}https://gitlab.com/p3r.one/apollo${normal}"