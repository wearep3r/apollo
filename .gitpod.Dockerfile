FROM gitpod/workspace-full

LABEL maintainer="Fabian Peter <fabian@peter.saarland>"

ENV TERRAFORM_VERSION=0.12.26

ENV TERRAFORM_INVENTORY_VERSION=0.9

ENV APOLLO_WHITELABEL_NAME=apollo

ENV APOLLO_CONFIG_DIR=$HOME/.${APOLLO_WHITELABEL_NAME}

ENV APOLLO_SPACES_DIR=${APOLLO_CONFIG_DIR}/.spaces

ENV TERM=xterm-256color 

ENV ANSIBLE_STRATEGY=mitogen_linear

ARG UNAME=gitpod
ARG UID=33333
ARG GROUP=sudo
ARG HOME=/home/gitpod
USER $UNAME

ARG DOCKER_IMAGE
ARG SHIPMATE_AUTHOR_URL
ARG SHIPMATE_AUTHOR
ARG SHIPMATE_BUILD_DATE
ARG SHIPMATE_CARGO_VERSION
ARG SHIPMATE_COMMIT_ID

LABEL org.label-schema.schema-version="1.0"
LABEL org.label-schema.build-date="$SHIPMATE_BUILD_DATE"
LABEL org.label-schema.name="$DOCKER_IMAGE"
LABEL org.label-schema.vendor="$SHIPMATE_AUTHOR"
LABEL org.label-schema.url="$SHIPMATE_AUTHOR_URL"
LABEL org.label-schema.version="$SHIPMATE_CARGO_VERSION"
LABEL org.label-schema.vcs-ref="$SHIPMATE_COMMIT_ID"

RUN mkdir -p ${APOLLO_CONFIG_DIR} ${APOLLO_SPACES_DIR} $HOME/.ssh $HOME/.config $HOME/.ansible/tmp $HOME/.ansible/cache $HOME/.ssh \
    && sudo mkdir -p /${APOLLO_WHITELABEL_NAME} /cargo /etc/ansible \
    && sudo chown gitpod:gitpod /cargo -R \
    && sudo chown gitpod:gitpod /apollo -R

RUN sudo apt-get update --allow-releaseinfo-change \
    && sudo apt-get -y --no-install-recommends install less man sudo rsync qrencode python3-jmespath fonts-firacode procps wget fontconfig mosh  git curl tar unzip make openssh-client sshpass nano jq apache2-utils \
    && pip install pytest black jmespath typer[all] anyconfig openshift  ansible==2.9 jsondiff docker ansible-lint molecule[lint] docker-compose \
    && sudo rm -rf /var/lib/apt/lists/*

WORKDIR /usr/local

RUN sudo curl -fsSL https://networkgenomics.com/try/mitogen-0.2.9.tar.gz -o mitogen-0.2.9.tar.gz \
    && sudo tar xvzf mitogen-0.2.9.tar.gz

RUN sudo curl -fsSL "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip" -o terraform.zip \
    && sudo unzip terraform.zip \
    && sudo rm terraform.zip \
    && sudo chmod +x terraform \
    && sudo mv terraform /usr/local/bin/

COPY ansible.cfg /etc/ansible/ansible.cfg

WORKDIR /${APOLLO_WHITELABEL_NAME}

RUN echo 'Ansible refuses to read from a world-writeable folder, hence' \
    && sudo chmod -v 700 $(pwd)

COPY requirements.yml requirements.yml

RUN ansible-galaxy install --ignore-errors -r requirements.yml

COPY docker-entrypoint.sh /docker-entrypoint.sh

COPY . .

WORKDIR ${APOLLO_SPACES_DIR}

ENTRYPOINT ["/docker-entrypoint.sh"]

SHELL ["/bin/bash", "-c"]

CMD ["/usr/local/bin/apollo"]

ARG BUILD_DATE

ARG SHIPMATE_CARGO_VERSION

ARG APOLLO_VERSION

ENV APOLLO_VERSION=$SHIPMATE_CARGO_VERSION

LABEL org.label-schema.build-date=$BUILD_DATE
