# Apollo commands

export APOLLO_EMOJI="🚀"
export PROMPT="${APOLLO_EMOJI} ${PROMPT}"

apollo::warn() { printf "%b[Warn]%b %s\n" '\e[0;33m' '\e[0m' "$@" >&2; }
apollo::info() { printf "%b[Info]%b %s\n" '\e[0;32m' '\e[0m' "$@" >&2; }

apollo::activate(){
  local cmd opts space
  cmd="echo {} | awk -F':' '{ print $1 }' | tr -d '\n' | xargs -r0 cat"
  opts="
    $APOLLO_FZF_DEFAULT_OPTS
    +m --tiebreak=index
    --bind=\"enter:execute(cd `echo $APOLLO_SPACES_DIR/{}` | ls -la | less)\"
  "
  #space=$(find $APOLLO_SPACES_DIR -mindepth 1 -name "*.space" -printf '%f\n' 2> /dev/null -type d | FZF_DEFAULT_OPTS=$APOLLO_FZF_DEFAULT_OPTS fzf --preview="$cmd")
  space=$(ag --noheading --nonumbers --nobreak IF0_ENVIRONMENT $APOLLO_SPACES_DIR/**/*.env | FZF_DEFAULT_OPTS=$APOLLO_FZF_DEFAULT_OPTS fzf --preview="$cmd")
  cd "$APOLLO_SPACES_DIR/$space"
  echo "Activating $APOLLO_SPACE_DIR"  | /usr/local/bin/lolcat
  echo "You are here: $APOLLO_SPACES_DIR/$space" | /usr/local/bin/lolcat
}

apollo::inspect() {
  local cmd opts graph files
  files=$(find ${1:-$APOLLO_SPACES_DIR} -type d)
  cmd="echo {} |grep -Eo '[a-f0-9]+' |head -1 |xargs -I% ls -1 % -- $files"
  opts="
      $APOLLO_FZF_DEFAULT_OPTS
      +s +m --tiebreak=index
      --bind=\"enter:execute($cmd | LESS='-R' less)\"
      --bind=\"ctrl-y:execute-silent(echo {} |grep -Eo '[a-f0-9]+' | head -1 | tr -d '\n' |${FORGIT_COPY_CMD:-pbcopy})\"
  "
  eval "find ${1:-$APOLLO_SPACES_DIR}" | FZF_DEFAULT_OPTS="$opts" fzf --preview="$cmd"
}

apollo::activate2() {
	find ${1:-$HOME/.apollo/.environments} | fzf --delimiter / --with-nth -1  --preview 'echo {}' --preview-window down:2 | export APOLLO_SPACE_DIR=$(cat)
	echo "Activating $APOLLO_SPACE_DIR"
	if [ -d $APOLLO_SPACE_DIR ];
	then
		env_files=`find $APOLLO_SPACE_DIR -maxdepth 1 -type f -name  "*.env"`

		for file in $env_files;
		do
			set -o allexport
			export $(grep -hv '^#' $file | xargs)
			set +o allexport
		done
	fi
	echo "Activated Space ${APOLLO_SPACE:-default}"
}

export APOLLO_CONFIG_DIR=$HOME/.apollo
export APOLLO_SPACES_DIR=${APOLLO_CONFIG_DIR}/.environments

export APOLLO_FZF_DEFAULT_OPTS="
$FZF_DEFAULT_OPTS
--cycle
--ansi
--height='99%'
--bind='alt-k:preview-up,alt-p:preview-up'
--bind='alt-j:preview-down,alt-n:preview-down'
--bind='ctrl-r:toggle-all'
--bind='ctrl-s:toggle-sort'
--bind='?:toggle-preview'
--bind='alt-w:toggle-preview-wrap'
--preview-window='right:60%'
+1
$APOLLO_FZF_DEFAULT_OPTS
"

# register aliases
# shellcheck disable=SC2139
if [[ -z "$APOLLO_NO_ALIASES" ]]; then
    alias "${apollo_activate:-activate}"='apollo::activate'
    alias "${apollo_list:-list}"='apollo::list'
    
fi