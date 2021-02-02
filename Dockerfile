FROM python:3.8.5-slim

LABEL maintainer="Fabian Peter <fabian@peter.saarland>"

ENV TERRAFORM_VERSION=0.12.26

ENV PACKER_VERSION=1.6.5

ENV TERRAFORM_INVENTORY_VERSION=0.9

ENV APOLLO_WHITELABEL_NAME=apollo

ENV APOLLO_APP_DIR=/home/apollo/app

ENV APOLLO_CONFIG_DIR=/home/apollo/.${APOLLO_WHITELABEL_NAME}

ENV APOLLO_SPACES_DIR=${APOLLO_CONFIG_DIR}/.spaces

ENV TERM=xterm-256color 

ENV ANSIBLE_STRATEGY=mitogen_linear

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

RUN apt-get update --allow-releaseinfo-change \
    && apt -y --no-install-recommends install less man sudo rsync qrencode wget fontconfig git curl tar unzip make openssh-client sshpass nano jq apache2-utils  \
    && useradd -l -u 33333 -G sudo -md /home/apollo -s /bin/bash -p $UNAME apollo apollo \
    && sed -i.bkp -e 's/%sudo\s\+ALL=(ALL\(:ALL\)\?)\s\+ALL/%sudo ALL=NOPASSWD:ALL/g' /etc/sudoers \
    && rm -rf /var/lib/apt/lists/*

USER apollo

COPY ansible.cfg /etc/ansible/ansible.cfg

RUN mkdir -p ${APOLLO_CONFIG_DIR} ${APOLLO_SPACES_DIR} /home/apollo/.ssh /home/apollo/.local/bin ${APOLLO_APP_DIR} /home/apollo/.config /home/apollo/.ansible/tmp /home/apollo/.ansible/cache \
    && sudo mkdir -p /etc/ansible /cargo \
    && sudo chown apollo:apollo /cargo -R

ENV PATH="$PATH:/home/apollo/.local/bin"

WORKDIR /home/apollo

RUN curl -fsSL https://networkgenomics.com/try/mitogen-0.2.9.tar.gz -o mitogen-0.2.9.tar.gz \
    && tar xvzf mitogen-0.2.9.tar.gz
    
USER root
WORKDIR /usr/local/bin

RUN curl -fsSL "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip" -o terraform.zip \
    && unzip terraform.zip \
    && rm terraform.zip \
    && chmod +x terraform \
    && curl -fsSL "https://releases.hashicorp.com/packer/${PACKER_VERSION}/packer_${PACKER_VERSION}_linux_amd64.zip" -o packer.zip \
    && unzip packer.zip \
    && rm packer.zip \
    && chmod +x packer

USER apollo

WORKDIR ${APOLLO_APP_DIR}

COPY ansible-requirements.yml ansible-requirements.yml
COPY requirements.txt requirements.txt

RUN sudo pip install -r requirements.txt \
    && sudo ansible-galaxy install --ignore-errors -r ansible-requirements.yml

RUN echo 'Ansible refuses to read from a world-writeable folder, hence' \
    && chmod -v 700 $(pwd)

COPY . .

COPY --chown=apollo:apollo docker-entrypoint.sh /docker-entrypoint.sh
#COPY --chown=apollo:apollo apollo-cli.py /home/apollo/.local/bin/apollo

#RUN chmod +x /home/apollo/.local/bin/apollo

WORKDIR ${APOLLO_SPACES_DIR}

ENTRYPOINT ["/docker-entrypoint.sh"]

CMD ["/home/apollo/.local/bin/apollo"]

ARG BUILD_DATE

ARG SHIPMATE_CARGO_VERSION

ARG APOLLO_VERSION

ENV APOLLO_VERSION=$SHIPMATE_CARGO_VERSION

LABEL org.label-schema.build-date=$BUILD_DATE