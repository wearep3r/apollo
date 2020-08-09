
#export APOLLO_EMOJI="🚀"
#export PROMPT="${PROMPT} ${APOLLO_EMOJI} "

# Text formatting
# https://stackoverflow.com/questions/2924697/how-does-one-output-bold-text-in-bash
bold=$(tput bold)
normal=$(tput sgr0)

apollo::warn() { printf "%b[${APOLLO_SPACE:-$APOLLO_WHITELABEL_NAME}]%b %s\n" '\e[0;33m' '\e[0m' "$@" >&2; }
apollo::info() { printf "%b[${APOLLO_SPACE:-$APOLLO_WHITELABEL_NAME}]%b %s\n" '\e[0;32m' '\e[0m' "$@" >&2; }
apollo::echo() { printf "%b[${APOLLO_SPACE:-$APOLLO_WHITELABEL_NAME}]%b %s\n" '\e[0;32m' '\e[0m' "$@" }
apollo::echo_n() { printf "%b[${APOLLO_SPACE:-$APOLLO_WHITELABEL_NAME}]%b %s" '\e[0;32m' '\e[0m' "$@" }

# Apollo commands
apollo::load() {
  if [ "$1" != "" ];
  then
    if [ "$1" = "." ];
    then
      export APOLLO_SPACE_DIR=$PWD
    else
      export APOLLO_SPACE_DIR=$APOLLO_SPACE_DIR
    fi
  else
    local cmd opts space
    #cmd="echo {} | cut -d ':' -f1 - | tr -d '\n' | xargs -r0 cat"
    cmd="grep -hvr '^#' $APOLLO_SPACES_DIR/{}/*.env 2> /dev/null"
    opts="
      $APOLLO_FZF_DEFAULT_OPTS
      --bind=\"enter:execute(cd $APOLLO_SPACES_DIR/{})\"
    "
    space=$(find $APOLLO_SPACES_DIR -mindepth 1 -name "*.space" -printf '%P\n' 2> /dev/null -type d | FZF_DEFAULT_OPTS=$APOLLO_FZF_DEFAULT_OPTS fzf --preview="$cmd")
    export APOLLO_SPACE_DIR=$APOLLO_SPACES_DIR/$space
  fi

  if [ -d $APOLLO_SPACE_DIR ];
	then
    # Unload previous Space
    apollo::unload > /dev/null

    # Go to current Space
    cd "$APOLLO_SPACE_DIR"

    # Migrate old files
    [ -f "dash1.env" ] && mv dash1.env infrastructure.apollo.env
    [ -f "dash1.plan" ] && mv dash1.plan infrastructure.apollo.plan
    [ -f "dash1.tfstate" ] && mv dash1.tfstate infrastructure.apollo.tfstate
    [ -f "dash1-zero.env" ] && mv dash1-zero.env nodes.apollo.env
    [ -f "zero.env" ] && mv zero.env apollo.env

    # Migrate old config
    sed -i 's/IF0_ENVIRONMENT/APOLLO_SPACE/g' *.env
    sed -i 's/ZERO_ADMIN_USER/APOLLO_ADMIN_USER/g' *.env
    sed -i 's/ZERO_ADMIN_PASSWORD/APOLLO_ADMIN_PASSWORD/g' *.env
    sed -i 's/ZERO_BASE_DOMAIN/APOLLO_BASE_DOMAIN/g' *.env
    sed -i 's/ZERO_APPS/APOLLO_APPS/g' *.env
    sed -i 's/ZERO_SMTP_SERVER/APOLLO_SMTP_SERVER/g' *.env
    sed -i 's/ZERO_SMTP_USERNAME/APOLLO_SMTP_USERNAME/g' *.env
    sed -i 's/ZERO_SMTP_PASSWORD/APOLLO_SMTP_PASSWORD/g' *.env
    sed -i 's/ZERO_SMTP_PORT/APOLLO_SMTP_PORT/g' *.env
    sed -i 's/ZERO_CLUSTER_NETWORK/APOLLO_CLUSTER_NETWORK/g' *.env
    sed -i 's/ZERO_INGRESS_IP/APOLLO_INGRESS_IP/g' *.env
    sed -i 's/ZERO_NODES_MANAGER/APOLLO_NODES_MANAGER/g' *.env
    sed -i 's/ZERO_NODES_WORKER/APOLLO_NODES_WORKER/g' *.env
    sed -i 's/ZERO_PRIVATE_INTERFACE/APOLLO_PRIVATE_INTERFACE/g' *.env
    sed -i 's/ZERO_PUBLIC_INTERFACE/APOLLO_PUBLIC_INTERFACE/g' *.env
    sed -i 's/ZERO_PROVIDER/APOLLO_PROVIDER/g' *.env

    # Load Space config
		for file in *.env;
		do
			set -o allexport
			export $(grep -hv '^#' $file | xargs) > /dev/null
			set +o allexport
		done

    # Add ssh-key
    [ -d ".ssh" ] && eval `ssh-agent -s` > /dev/null && ssh-add -k .ssh/id_rsa > /dev/null 2>&1
    
    export APOLLO_INGRESS_IP=${APOLLO_INGRESS_IP:-"127.0.0.1"}
    export APOLLO_SPACE=${APOLLO_SPACE}
    export APOLLO_BASE_DOMAIN="${APOLLO_BASE_DOMAIN:-${APOLLO_INGRESS_IP}.xip.io}"
    PLATFORM_DOMAIN="${APOLLO_SPACE}.${APOLLO_BASE_DOMAIN}"
    export APOLLO_PLATFORM_DOMAIN="${APOLLO_PLATFORM_DOMAIN:-${PLATFORM_DOMAIN}}"
    export APOLLO_BACKPLANE_ENABLED=${APOLLO_BACKPLANE_ENABLED:-$BACKPLANE_ENABLED}
    export APOLLO_FEDERATION_ENABLED=${APOLLO_FEDERATION_ENABLED:-0}
    export APOLLO_ADMIN_USER=${APOLLO_ADMIN_USER:-"admin"}
    export APOLLO_ADMIN_PASSWORD=${APOLLO_ADMIN_PASSWORD:-"insecure!"}
    export APOLLO_RUNNER_ENABLED=${APOLLO_RUNNER_ENABLED:-$RUNNER_ENABLED}
    export TF_IN_AUTOMATION=1
    export TF_VAR_environment=${APOLLO_SPACE}
    export TF_VAR_ssh_public_key_file=${APOLLO_SPACE_DIR}/.ssh/id_rsa.pub
    export DOCKER_HOST=ssh://root@${APOLLO_INGRESS_IP}
    export LETSENCRYPT_ENABLED=${LETSENCRYPT_ENABLED:-"0"}
    if [ "$LETSENCRYPT_ENABLED" != "0" ];
    then
      export HTTP_ENDPOINT=https
    else
      export HTTP_ENDPOINT=http
    fi
    export LOKI_ADDR=${HTTP_ENDPOINT}://logs.${APOLLO_PLATFORM_DOMAIN}

    apollo::inspect
	fi
}

apollo::unload() {
  apollo::echo "Unloading ${APOLLO_SPACE}"
  unset APOLLO_SPACE
  cd ${APOLLO_SPACES_DIR}
}

apollo::terraform_init() {
  if [[ ! -z "$APOLLO_SPACE" ]];
  then
    apollo::echo "Terraform > Init"

    exec 5>&1

    if [ "$APOLLO_PROVIDER" != "generic" ];
    then
      if [ ! -d /apollo/modules/${APOLLO_PROVIDER}/.terraform ];
      then
        apollo_status=$(
          cd /apollo/modules/$APOLLO_PROVIDER
          terraform init -compact-warnings -input=false >&5
        )
      fi
    fi
    echo $apollo_status
  else
    apollo::echo "No Space selected. Use \`apollo load\`"
  fi
}

apollo::terraform_plan() {
  if [[ ! -z "$APOLLO_SPACE" ]];
  then
    apollo::echo "Terraform > Plan"

    TF_PLAN_PATH=${APOLLO_SPACE_DIR}/infrastructure.apollo.plan
    TF_STATE_PATH=${APOLLO_SPACE_DIR}/infrastructure.apollo.tfstate

    exec 5>&1

    if [ "$APOLLO_PROVIDER" != "generic" ];
    then
      apollo::terraform_init
      
      if [ ! -f $TF_PLAN_PATH ];
      then
        apollo_status=$(
          cd /apollo/modules/$APOLLO_PROVIDER
          
          terraform plan -lock=true -compact-warnings -input=false -out=${TF_PLAN_PATH} -state=${TF_STATE_PATH} >&5
        )
      fi
    fi
    echo $apollo_status
  else
    apollo::echo "No Space selected. Use \`apollo load\`"
  fi
}

apollo::terraform_apply() {
  if [[ ! -z "$APOLLO_SPACE" ]];
  then
    apollo::echo "Terraform > Apply"

    TF_PLAN_PATH=${APOLLO_SPACE_DIR}/infrastructure.apollo.plan
    TF_STATE_PATH=${APOLLO_SPACE_DIR}/infrastructure.apollo.tfstate

    exec 5>&1

    if [ "$APOLLO_PROVIDER" != "generic" ];
    then
      apollo::terraform_plan
      
      if [ ! -f $TF_STATE_PATH ];
      then
        apollo_status=$(
          cd /apollo/modules/$APOLLO_PROVIDER
          
          terraform apply -compact-warnings -state=${TF_STATE_PATH} -auto-approve ${TF_PLAN_PATH} >&5
          terraform output -state=${TF_STATE_PATH} | tr -d ' ' > ${APOLLO_SPACE_DIR}/nodes.apollo.env
        )
        apollo::load $APOLLO_SPACE_DIR
      fi
    fi
    echo $apollo_status
  else
    apollo::echo "No Space selected. Use \`apollo load\`"
  fi
}

apollo::deploy() {
  if [[ ! -z "$APOLLO_SPACE" ]];
  then
    apollo::echo "Deploying Space '$APOLLO_SPACE'"
    apollo::echo "VERBOSITY: '$ANSIBLE_VERBOSITY'"

    # https://stackoverflow.com/questions/15153158/how-to-redirect-an-output-file-descriptor-of-a-subshell-to-an-input-file-descrip
    exec 5>&1

    if [ "$1" = "apps" ];
    then
      if [ "$2" != "" ];
      then
        apollo::echo "Deploying App $2"
      else
        apollo::echo "Deploying Apps"

        apollo_status=$(
          export ANSIBLE_VERBOSITY=${ANSIBLE_VERBOSITY}
          cd /apollo
          ansible-playbook provision.yml --flush-cache --tags "provision_apps,always" >&5
        )
        echo $apollo_status
      fi
    elif [ "$1" = "backplane" ];
    then
      if [ "$2" != "" ];
      then
        apollo::echo "Deploying Backplane App $2"

        apollo_status=$(
          export ANSIBLE_VERBOSITY=${ANSIBLE_VERBOSITY}
          cd /apollo
          ansible-playbook provision.yml --flush-cache --tags "app_${2},always" >&5
        )
        echo $apollo_status
      else
        apollo::echo "Deploying Backplane"

        apollo_status=$(
          export ANSIBLE_VERBOSITY=${ANSIBLE_VERBOSITY}
          cd /apollo
          ansible-playbook provision.yml --flush-cache --tags "provision_backplane,always" >&5
        )
        echo $apollo_status
      fi
    else
      apollo::terraform_apply

      apollo_status=$(
        export ANSIBLE_VERBOSITY=${ANSIBLE_VERBOSITY}
        cd /apollo
        ansible-playbook provision.yml --flush-cache >&5
      )
      echo $apollo_status
    fi
  else
    apollo::echo "No Space selected. Use \`apollo load\`"
  fi
}

apollo::destroy() {
  if [[ ! -z "$APOLLO_SPACE" ]];
  then
    apollo::echo "Terraform > Destroy"

    TF_PLAN_PATH=${APOLLO_SPACE_DIR}/infrastructure.apollo.plan
    TF_STATE_PATH=${APOLLO_SPACE_DIR}/infrastructure.apollo.tfstate

    # https://stackoverflow.com/questions/15153158/how-to-redirect-an-output-file-descriptor-of-a-subshell-to-an-input-file-descrip
    exec 5>&1

    if [ "$APOLLO_PROVIDER" != "generic" ];
    then
      apollo_status=$(
        cd /apollo/modules/$APOLLO_PROVIDER
        terraform destroy -compact-warnings -state=${TF_STATE_PATH} -auto-approve 
        rm -rf ${TF_STATE_PATH} ${TF_STATE_PATH}.backup ${TF_PLAN_PATH} ${APOLLO_SPACE_DIR}/nodes.apollo.env
      )
    else
      apollo_status=$(
        echo "Nothing to do" >&5
      )
    fi
    echo $apollo_status
  else
    apollo::echo "No Space selected. Use \`apollo load\`"
  fi
}

apollo::inspect() {
  if [[ ! -z "$APOLLO_SPACE" ]];
  then
    apollo::echo "🚀 ${bold}Space: ${normal}$APOLLO_SPACE"
    apollo::echo " ∟ 🌐 ${bold}Base Domain: ${normal}$APOLLO_BASE_DOMAIN"
    apollo::echo " ∟ 🤖 ${bold}User: ${normal}$APOLLO_ADMIN_USER"
    apollo::echo " ∟ 🙊 ${bold}Password: ${normal}$APOLLO_ADMIN_PASSWORD"

    apollo::echo "🟢 ${bold}Nodes: ${normal}"

    mngr_cnt=0
    for manager in $(echo $APOLLO_NODES_MANAGER | sed "s/,/ /g")
    do
      apollo::echo " ∟ 🟢 ${bold}$APOLLO_SPACE-manager-$mngr_cnt - ${manager}${normal}"
      mngr_cnt=$((mngr_cnt+1))
    done

    wrkr_cnt=0
    for worker in $(echo $APOLLO_NODES_WORKER | sed "s/,/ /g")
    do
      apollo::echo " ∟ 🟢 ${bold}$APOLLO_SPACE-worker-$wrkr_cnt - ${worker}${normal}"
      wrkr_cnt=$((wrkr_cnt+1))
    done

    if [ "$APOLLO_FEDERATION_ENABLED" != "0" ];
    then
      apollo::echo "🟢 ${bold}Federation: ${normal}Enabled"
      
      for space in $(echo $APOLLO_FEDERATION_SPACES | sed "s/,/ /g")
      do
        apollo::echo " ∟ 🟢 ${bold}${space}${normal}"
      done
    else
      apollo::warn "❌ ${bold}Federation: ${normal}Disabled"
    fi

    if [ "$APOLLO_BACKPLANE_ENABLED" != "0" ];
    then
      apollo::echo "🟢 ${bold}Backplane: ${normal}Enabled"
      apollo::echo " ∟ 🟢 ${bold}Portainer: ${normal}${HTTP_ENDPOINT}://${APOLLO_ADMIN_USER}:${APOLLO_ADMIN_PASSWORD}@portainer.$APOLLO_PLATFORM_DOMAIN"
      apollo::echo " ∟ 🟢 ${bold}Traefik: ${normal}${HTTP_ENDPOINT}://${APOLLO_ADMIN_USER}:${APOLLO_ADMIN_PASSWORD}@proxy.$APOLLO_PLATFORM_DOMAIN"
      apollo::echo " ∟ 🟢 ${bold}Prometheus: ${normal}${HTTP_ENDPOINT}://${APOLLO_ADMIN_USER}:${APOLLO_ADMIN_PASSWORD}@prometheus.$APOLLO_PLATFORM_DOMAIN"
      apollo::echo " ∟ 🟢 ${bold}Grafana: ${normal}${HTTP_ENDPOINT}://grafana.$APOLLO_PLATFORM_DOMAIN"
    else
      apollo::warn "❌ ${bold}Backplane: ${normal}Disabled"
    fi

    if [ ! -z "$APOLLO_RUNNER_ENABLED" ];
    then
      apollo::echo "🟢 ${bold}GitLab Runner: ${normal}Enabled"

      RUNNER_BUILD_ENABLED=${RUNNER_BUILD_ENABLED:-"1"}
      if [ "$RUNNER_BUILD_ENABLED" != "0" ];
      then
        apollo::echo " ∟ 🟢 ${bold}Build: ${normal}Enabled"
      else
        apollo::echo " ∟ 🔴 ${bold}Build: ${normal}Disabled"
      fi

      RUNNER_DEPLOY_ENABLED=${RUNNER_DEPLOY_ENABLED:-"1"}
      if [ "$RUNNER_DEPLOY_ENABLED" != "0" ];
      then
        apollo::echo " ∟ 🟢 ${bold}Deploy: ${normal}Enabled"
      else
        apollo::echo " ∟ 🔴 ${bold}Deploy: ${normal}Disabled"
      fi
      apollo::echo " ∟ 🟢 ${bold}Coordinator URL: ${normal}${GITLAB_RUNNER_COORDINATOR_URL:-https://gitlab.com}"
      apollo::echo " ∟ 🟢 ${bold}Token: ${normal}${GITLAB_RUNNER_TOKEN}"
    else
      apollo::warn "🔴 ${bold}GitLab Runner: ${normal}Disabled"
    fi

    if [ ! -z "$APOLLO_APPS" ];
    then
      apollo::echo "🟢 ${bold}Apps: ${normal}"
      for app in $(echo $APOLLO_APPS | sed "s/,/ /g")
      do
        apollo::echo " ∟ 🟢 ${bold}${app}${normal}"
      done
    else
      apollo::warn "🔴 ${bold}Apps: ${normal}Disabled"
    fi

    #apollo::echo `git status`
  else
    apollo::echo "No Space selected. Use \`apollo load\`"
  fi
}

apollo::init() {
  if [[ ! -z "$APOLLO_SPACE" ]];
  then
    apollo::unload > /dev/null
  fi

  unset SPACE_INFRASTRUCTURE
  unset SPACE_CONFIG

  # Load Defaults
  set -o allexport
  export $(grep -hv '^#' $APOLLO_CONFIG_DIR/apollo.env | xargs) > /dev/null
  set +o allexport

  SPACE_CONFIG=()

  apollo::echo "Initializing new Space"

  # Prompt
  # Name
  if [ ! -z "$1" ];
  then
    APOLLO_SPACE=$1
    apollo::echo "${bold}Name: ${normal}$1"
  else
    apollo::echo_n "${bold}Name: ${normal}"
    read APOLLO_SPACE
  fi
  SPACE_CONFIG+=("APOLLO_SPACE=${APOLLO_SPACE}")

  # Sync URL
  if [ ! -z "$2" ];
  then
    APOLLO_SYNC=1
    APOLLO_GIT_REMOTE=$2
    SPACE_CONFIG+=("APOLLO_GIT_REMOTE=${APOLLO_GIT_REMOTE}")
    apollo::echo "${bold}Remote Repository: ${normal}$2"
  else
    apollo::echo_n "${bold}Do you want to sync this Space with a remote repository? ${normal}[y/N] "

    read APOLLO_SYNC
    
    case $APOLLO_SYNC in
        [Yy]* ) APOLLO_SYNC=1;;
        [Nn]* ) APOLLO_SYNC=0;;
        * ) APOLLO_SYNC=0;;
    esac
    
    if [ "$APOLLO_SYNC" != "0" ];
    then
      apollo::echo_n "${bold}Remote Repository: ${normal}"

      read APOLLO_GIT_REMOTE
    fi
    SPACE_CONFIG+=("APOLLO_GIT_REMOTE=${APOLLO_GIT_REMOTE}")
  fi

  # Cloud Provider
  if [ ! -z "$3" ];
  then
    APOLLO_PROVIDER=$3
    apollo::echo "${bold}Apollo Provider: ${normal}$3"
  else
    apollo::echo_n "${bold}Cloud Provider (generic,hcloud,digitalocean,aws): ${normal}"

    read APOLLO_PROVIDER_INPUT
    APOLLO_PROVIDER=${APOLLO_PROVIDER_INPUT:-generic}
  fi
  SPACE_CONFIG+=("APOLLO_PROVIDER=${APOLLO_PROVIDER}")

  if [ "$APOLLO_PROVIDER" != "generic" ];
  then
    # Authentication
    if [ "$APOLLO_PROVIDER" = "aws" ]
    then
      apollo::echo_n "${bold}AWS Access Key ID: ${normal}"
      read AWS_ACCESS_KEY_ID

      apollo::echo_n "${bold}AWS Secret Access Key: ${normal}"
      read AWS_SECRET_ACCESS_KEY
      SPACE_INFRASTRUCTURE+=("AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}")
      SPACE_INFRASTRUCTURE+=("AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}")
    fi
    
    if [ "$APOLLO_PROVIDER" = "hcloud" ]
    then
      apollo::echo_n "${bold}HCLOUD Token: ${normal}"
      read HCLOUD_TOKEN_INPUT
      HCLOUD_TOKEN=${HCLOUD_TOKEN_INPUT:-$HCLOUD_TOKEN}
      SPACE_INFRASTRUCTURE+=("HCLOUD_TOKEN=${HCLOUD_TOKEN}")
    fi

    if [ "$APOLLO_PROVIDER" = "digitalocean" ]
    then
      apollo::echo_n "${bold}Digitalocean Access Token: ${normal}"
      read DIGITALOCEAN_ACCESS_TOKEN
      SPACE_INFRASTRUCTURE+=("DIGITALOCEAN_ACCESS_TOKEN=${DIGITALOCEAN_ACCESS_TOKEN}")
    fi

    # Manager Nodes
    if [ ! -z "$4" ];
    then
      TF_VAR_manager_instances=$4
      apollo::echo "${bold}Manager instances: ${normal}$4"
    else
      apollo::echo_n "${bold}Manager instances: ${normal}"

      read TF_VAR_manager_instances
    fi
    SPACE_INFRASTRUCTURE+=("TF_VAR_manager_instances=${TF_VAR_manager_instances}")

    # Worker Nodes
    if [ ! -z "$5" ];
    then
      TF_VAR_worker_instances=$5
      apollo::echo "${bold}Worker instances: ${normal}$5"
    else
      apollo::echo_n "${bold}Worker instances: ${normal}"

      read TF_VAR_worker_instances
    fi 
    SPACE_INFRASTRUCTURE+=("TF_VAR_worker_instances=${TF_VAR_worker_instances}")
  else
    # Manager Nodes
    if [ ! -z "$4" ];
    then
      APOLLO_NODES_MANAGER=$4
      apollo::echo "${bold}Manager IPs (comma separated): ${normal}$4"
    else
      apollo::echo_n "${bold}Manager IPs (comma separated): ${normal}"

      read APOLLO_NODES_MANAGER
    fi
    SPACE_INFRASTRUCTURE+=("APOLLO_NODES_MANAGER=${APOLLO_NODES_MANAGER}")

    # Worker Nodes
    if [ ! -z "$5" ];
    then
      APOLLO_NODES_WORKER=$5
      apollo::echo "${bold}Worker IPs (comma separated): ${normal}$5"
    else
      apollo::echo_n "${bold}Worker IPs (comma separated): ${normal}"

      read APOLLO_NODES_WORKER
    fi 
    SPACE_INFRASTRUCTURE+=("APOLLO_NODES_WORKER=${APOLLO_NODES_WORKER}")
  fi

  # Base Domain
  if [ ! -z "$6" ];
  then
    APOLLO_BASE_DOMAIN=$6
    apollo::echo "${bold}Base domain: ${normal}$6"
  else
    apollo::echo_n "${bold}Base domain: ${normal}"

    read APOLLO_BASE_DOMAIN
  fi 
  SPACE_CONFIG+=("APOLLO_BASE_DOMAIN=${APOLLO_BASE_DOMAIN}")

  # LetsEncrypt
  apollo::echo_n "${bold}Enable LetsEncrypt? ${normal}[y/N] "

  read APOLLO_LETSENCRYPT
  
  case $APOLLO_LETSENCRYPT in
      [Yy]* ) LETSENCRYPT_ENABLED=1;;
      [Nn]* ) LETSENCRYPT_ENABLED=0;;
      * ) LETSENCRYPT_ENABLED=0;;
  esac
  
  if [ "$LETSENCRYPT_ENABLED" != "0" ];
  then
    apollo::echo_n "${bold}LetsEncrypt E-Mail: ${normal}"

    read LETSENCRYPT_EMAIL

    SPACE_CONFIG+=("LETSENCRYPT_EMAIL=${LETSENCRYPT_EMAIL}")
    SPACE_CONFIG+=("LETSENCRYPT_ENABLED=${LETSENCRYPT_ENABLED}")
  fi

  export APOLLO_SPACE_DIR=$APOLLO_SPACES_DIR/$APOLLO_SPACE.space

  mkdir -p "$APOLLO_SPACE_DIR"

  cd $APOLLO_SPACE_DIR

  if [ ! -d ".ssh" ];
  then
    mkdir -p .ssh
    ssh-keygen -b 4096 -t rsa -q -N "" -f .ssh/id_rsa 
  fi

  if [ ! -f apollo.env ] && printf "%s\n" "${SPACE_CONFIG[@]}" > apollo.env  
  if [ ! -f infrastructure.apollo.env ] && printf "%s\n" "${SPACE_INFRASTRUCTURE[@]}" > infrastructure.apollo.env

  apollo::load .
}


apollo::enter() {
  if [[ ! -z "$APOLLO_SPACE" ]];
  then
    apollo::echo "Entering Space '$APOLLO_SPACE'"
    ssh -l root -i $PWD/.ssh/id_rsa ${APOLLO_INGRESS_IP}
  else
    apollo::echo "No Space selected. Use \`apollo load\`"
  fi
}

apollo::plan() {
  if [[ ! -z "$APOLLO_SPACE" && ! -z "$APOLLO_PROVIDER" ]];
  then
    apollo::echo "Planning Space '$APOLLO_SPACE'"
    apollo_status=$(
      cd /apollo
      make plan
    )
    echo $apollo_status
  else
    apollo::echo "No Space selected. Use 'apollo activate'"
  fi
}

apollo::destroy() {
  if [[ ! -z "$APOLLO_SPACE" && ! -z "$APOLLO_PROVIDER" ]];
  then
    apollo::echo "Destroying Space '$APOLLO_SPACE'"
    apollo_status=$(
      cd /apollo
      make destroy
    )
    echo $apollo_status
  else
    apollo::echo "No Space selected. Use 'apollo activate'"
  fi
}

# Defaults
export APOLLO_CONFIG_DIR=$HOME/.${APOLLO_WHITELABEL_NAME:-apollo}
export APOLLO_SPACES_DIR=${APOLLO_CONFIG_DIR}/.spaces
export APOLLO_DEVELOPMENT=${APOLLO_DEVELOPMENT:-0}
export APOLLO_REMOTE_DIR=${APOLLO_REMOTE_DIR:-/srv/.apollo}
export ANSIBLE_VERBOSITY=${VERBOSITY:-${ANSIBLE_VERBOSITY:-0}}
export APOLLO_PROVIDER=${APOLLO_PROVIDER:-generic}

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
    alias "${apollo_load:-load}"='apollo::load'
    alias "${apollo_inspect:-inspect}"='apollo::inspect'
    alias "${apollo_deploy:-deploy}"='apollo::deploy'
    alias "${apollo_destroy:-destroy}"='apollo::destroy'
    alias "${apollo_enter:-enter}"='apollo::enter'
    alias "${apollo_plan:-plan}"='apollo::plan'
    alias "${apollo_unload:-unload}"='apollo::unload'
    alias "${apollo_init:-init}"='apollo::init'
fi