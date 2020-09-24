# If you come from bash you might have to change your $PATH.
setopt aliases
export GOPATH=$HOME/go
export PATH=$HOME/bin:/usr/local/bin:$GOPATH/bin:/usr/local/opt/make/libexec/gnubin:$PATH
export ZSH="/root/.oh-my-zsh"
export HISTFILE="/root/.apollo/.history"

ZSH_THEME="flazz"

#ZSH_THEME="alanpeabody"
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

_apollo_completion() {
  eval $(env _TYPER_COMPLETE_ARGS="${words[1,$CURRENT]}" _APOLLO_COMPLETE=complete_zsh apollo)
}

#source /apollo/apollo.plugin.zsh

# Generic commands
alias reload="source ~/.zshrc"
alias ls='lsd'
alias grep='grep --color'
alias zshrc="nano ~/.zshrc"
alias -g Z='| fzf'
alias less="bat"

export PROMPT='%{$fg[green]%}%m%{$reset_color%}@%{$fg_bold[cyan]%}${APOLLO_VERSION}%{$reset_color%}%{${fg_bold[magenta]}%} :: %{$reset_color%}%{${fg[green]}%}%c $(git_prompt_info)%{${fg_bold[$CARETCOLOR]}%}%#%{${reset_color}%} '
export ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg_bold[cyan]%}"
export ZSH_THEME_GIT_PROMPT_SUFFIX=" %{$reset_color%}"
