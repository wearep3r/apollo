#!/bin/zsh

apollo::reset() {
  # Source defaults file to reset everything
  set -o allexport
  export $(grep -hv '^#' /apollo/defaults.env | xargs) > /dev/null
  set +o allexport
} 

apollo::populate() {
  apollo::reset > /dev/null
  
  # Load Space config
  for file in *.env;
  do
    source $file
  done
}

# apollo::test expects to be run inside APOLLO_SPACE_DIR
# it will load and populate all environment variables
# with apollo::populate
apollo::test() {
  apollo::populate

  severity=0

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

  exit $severity
}


if [[ "$1" = "test" ]];
then
  apollo::test
fi
