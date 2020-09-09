#!/bin/zsh

apollo::populate() {
  source /apollo/defaults.env

  # if not in CI
  if ! [ "$CI" = "1" ];
  then
    # load defaults from ~/.apollo/apollo.env
    # Hint: this could include global config like HCLOUD_TOKEN
    # that would be relevant for multiple spaces
    if [ -f $APOLLO_CONFIG_DIR/apollo.env ];
    then
      set -o allexport
      export $(grep -hv '^#' $APOLLO_CONFIG_DIR/apollo.env | xargs) > /dev/null
      set +o allexport
    fi
  fi

  # Determine APOLLO_SPACE_DIR
  # Hint: defaults to $CI_BUILDS_DIR which is a default
  # environment variable in GitLab CI; it's where the builds
  # are running on a gitlab-runner container
  export APOLLO_SPACE_DIR="${PWD:-$CI_BUILDS_DIR}"
  
  # Load space-related config from .env files
  # in APOLLO_SPACE_DIR
  for file in $APOLLO_SPACE_DIR/*.env;
  do
    set -o allexport
    export $(grep -hv '^#' $file | xargs) > /dev/null
    set +o allexport
  done

  # reload defaults.env to build
  # space-related dynamic config (e.g. APOLLO_BASE_DOMAIN which
  # requires APOLLO_SPACE to be set first)
  source /apollo/defaults.env

  # If Debug is enabled, be a little more verbose
  if [ "$ANSIBLE_VERBOSITY" -gt 0 ];
  then
    echo "Working on space ${APOLLO_SPACE} in ${APOLLO_SPACE_DIR}"
  fi
}

# apollo::test expects to be run inside $APOLLO_SPACE_DIR
# it will load and populate all environment variables
# with apollo::populate
apollo::test() {
  # Severity of detected issues
  # Will be increased by the tests below
  # Should result in a traffic-light-like rating
  # 0-10 is GREEN
  # 11-80 is YELLOW
  # 81-100+ is RED
  severity=0

  # Mandatory parameters for a minimum config
  mandatory=(
    APOLLO_SPACE
    APOLLO_NODES_MANAGER
    APOLLO_INGRESS_IP
  )

  # Test for no space name defined
  if [ "$APOLLO_SPACE" = "" ];
  then
    sev=5
    echo "+$sev No space found"
    severity=$((severity+$sev))
  fi

  # Test for default space name
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
  if [ "$APOLLO_ADMIN_PASSWORD" = "insecure" ];
  then
    sev=5
    echo "+$sev Using default password '$APOLLO_ADMIN_PASSWORD'"
    severity=$((severity+$sev))
  fi

  # Test for mandatory options
  # for any option found in the mandatory array
  for option in ${mandatory[@]};
  do
    # check if the environment variable exists
    # e.g. $option=APOLLO_SPACE, looks for APOLLO_SPACE
    # in the environment
    if ! [[ -v "$option" ]];
    then
      # severity is 100 to break the test
      sev=100
      echo "+$sev Missing mandatory option '$option'"
      severity=$((severity+$sev))
    fi
  done

  echo "Tests finished. Severity is $severity"

  # use calculated severity as exit code
  # fails CI pipelines if $severity > 0
  exit $severity
}

# terraform init
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

# terraform plan
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

# terraform apply
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

# ansible provision
apollo::deploy() {
  echo "Deploying apollo space $APOLLO_SPACE"

  apollo_status=$(
    cd /apollo
    env
    ANSIBLE_VERBOSITY=${ANSIBLE_VERBOSITY:-2} ansible-playbook provision.yml --flush-cache
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

  env

  apollo::deploy
fi