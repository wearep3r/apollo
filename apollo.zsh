#!/bin/zsh

apollo::populate() {
  source /apollo/defaults.env

  # Load Defaults
  if ! [ "$CI" = "1" ];
  then
    if [ -f $APOLLO_CONFIG_DIR/apollo.env ];
    then
      set -o allexport
      export $(grep -hv '^#' $APOLLO_CONFIG_DIR/apollo.env | xargs) > /dev/null
      set +o allexport
    fi
  fi

  export APOLLO_SPACE_DIR="${PWD:-$CI_BUILDS_DIR}"
  
  # Load Space config
  for file in *.env;
  do
    set -o allexport
    export $(grep -hv '^#' $file | xargs) > /dev/null
    set +o allexport
  done

  # re-source defaults to build
  # space-related dynamic config
  source /apollo/defaults.env

  if [ "$ANSIBLE_VERBOSITY" -gt 0 ];
  then
    echo "Working on space ${APOLLO_SPACE} in ${APOLLO_SPACE_DIR}"
  fi
}

# apollo::test expects to be run inside $APOLLO_SPACE_DIR
# it will load and populate all environment variables
# with apollo::populate
apollo::test() {
  severity=0

  mandatory=(
    APOLLO_SPACE
    APOLLO_NODES_MANAGER
    APOLLO_INGRESS_IP
  )

  # Test for no space
  if [ "$APOLLO_SPACE" = "" ];
  then
    sev=5
    echo "+$sev No space found"
    severity=$((severity+$sev))
  fi

  # Test for default space
  if [ "$APOLLO_SPACE" = "apollo" ];
  then
    echo "+0 Using default space '$APOLLO_SPACE'"
    severity=$((severity+0))
  fi

  # Test for default user
  if [ "$APOLLO_ADMIN_USER" = "admin" ];
  then
    echo "+0 Using default user '$APOLLO_ADMIN_USER'"
    severity=$((severity+0))
  fi

  # Test for default password
  if [ "$APOLLO_ADMIN_PASSWORD" = "insecure!" ];
  then
    sev=5
    echo "+$sev Using default password '$APOLLO_ADMIN_PASSWORD'"
    severity=$((severity+$sev))
  fi

  # Test for mandatory
  for option in ${mandatory[@]};
  do
    if ! [[ -v "$option" ]];
    then
      sev=100
      echo "+$sev Missing mandatory option '$option'"
      severity=$((severity+$sev))
    fi
  done

  echo "Tests finished. Severity is $severity"

  exit $severity
}

apollo::init() {
  if [ ! -d /apollo/modules/${APOLLO_PROVIDER}/.terraform ];
  then
    apollo_status=$(
      cd /apollo/modules/$APOLLO_PROVIDER
      terraform init -compact-warnings -input=false
    )
    echo $apollo_status
  fi
}

apollo::plan() {
    # TODO: an existing plan-file does not mean we don't want to rewrite the plan
    if [ ! -f $TF_PLAN_PATH ];
    then
      apollo_status=$(
        cd /apollo/modules/$APOLLO_PROVIDER
        terraform plan -lock=true -compact-warnings -input=false -out=${TF_PLAN_PATH} -state=${TF_STATE_PATH}
      )
    fi

    echo $apollo_status
}

apollo::apply() {
  # TODO: an existing plan-file does not mean we don't want to rewrite the plan
  if [ ! -f $TF_STATE_PATH ];
  then
    apollo_status=$(
      cd /apollo/modules/$APOLLO_PROVIDER
      
      terraform apply -compact-warnings -state=${TF_STATE_PATH} -auto-approve ${TF_PLAN_PATH}
      terraform output -state=${TF_STATE_PATH} | tr -d ' ' > ${APOLLO_SPACE_DIR}/nodes.apollo.env
    )
    echo $apollo_status

    apollo::populate
  fi
}

apollo::deploy() {
  echo "Deploying apollo space $APOLLO_SPACE"

  apollo_status=$(
    cd /apollo
    ansible-playbook provision.yml --flush-cache
  )
  echo $apollo_status
}

if [[ "$1" = "test" ]];
then
  apollo::populate
  apollo::test
fi

if [[ "$1" = "deploy" ]];
then
  apollo::populate
  
  if [ "$APOLLO_PROVIDER" != "generic" ];
  then
    export TF_PLAN_PATH="${APOLLO_SPACE_DIR}/infrastructure.apollo.plan"
    export TF_STATE_PATH="${APOLLO_SPACE_DIR}/infrastructure.apollo.tfstate"

    apollo::init
    apollo::plan
    apollo::apply
  fi

  apollo::deploy
fi