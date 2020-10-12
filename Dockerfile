FROM python:3.8.5-slim

LABEL maintainer="Fabian Peter <fabian@peter.saarland>"

ENV TERRAFORM_VERSION=0.12.26

ENV TERRAFORM_INVENTORY_VERSION=0.9

ENV APOLLO_WHITELABEL_NAME=apollo

ENV APOLLO_CONFIG_DIR=/root/.${APOLLO_WHITELABEL_NAME}

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

RUN mkdir -p ${APOLLO_CONFIG_DIR} ${APOLLO_SPACES_DIR} /${APOLLO_WHITELABEL_NAME} /root/.ssh /root/.local/share/fonts /root/.config /usr/local/share/fonts /cargo /root/.ansible/tmp /root/.ansible/cache /ansible /ansible/roles /inventory /roles /collections /etc/ansible /root/.ssh
# silversearcher-ag
RUN apt-get update --allow-releaseinfo-change \
    && apt-get -y --no-install-recommends install zsh less man sudo rsync qrencode python3-jmespath fonts-firacode procps wget fontconfig mosh  git curl tar unzip make openssh-client sshpass nano jq apache2-utils \
    && sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)" \
    && git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf \
    && ~/.fzf/install --all --key-bindings --completion \
    && pip install jmespath typer[all] anyconfig openshift  ansible==2.9 jsondiff docker ansible-lint molecule[lint] docker-compose \
    && wget https://github.com/source-foundry/Hack/releases/download/v3.003/Hack-v3.003-ttf.zip \
    && unzip Hack-v3.003-ttf.zip \
    && mv ttf/*.ttf /usr/local/share/fonts/. \
    && rm -rf ttf Hack-v3.003-ttf.zip \
    && fc-cache -f \
    && wget https://github.com/Peltoche/lsd/releases/download/0.18.0/lsd_0.18.0_amd64.deb \
    && wget https://github.com/sharkdp/bat/releases/download/v0.15.4/bat_0.15.4_amd64.deb \
    && dpkg -i lsd_0.18.0_amd64.deb \
    && dpkg -i bat_0.15.4_amd64.deb \
    && rm bat_0.15.4_amd64.deb \
    && rm lsd_0.18.0_amd64.deb \
    && git clone https://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/plugins/zsh-autosuggestions \
    && git clone https://github.com/zsh-users/zsh-completions ~/.oh-my-zsh/plugins/zsh-completions \
    && git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.oh-my-zsh/plugins/zsh-syntax-highlighting \
    && git clone https://github.com/lincheney/fzf-tab-completion.git ~/.oh-my-zsh/plugins/fzf-tab-completion \
    && rm -rf /var/lib/apt/lists/* \
    && chsh -s /bin/zsh

WORKDIR /usr/local

RUN curl -fsSL https://networkgenomics.com/try/mitogen-0.2.9.tar.gz -o mitogen-0.2.9.tar.gz \
    && tar xvzf mitogen-0.2.9.tar.gz

RUN curl -fsSL "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip" -o terraform.zip \
    && unzip terraform.zip \
    && rm terraform.zip \
    && chmod +x terraform \
    && mv terraform /usr/local/bin/

COPY ansible.cfg /etc/ansible/ansible.cfg

WORKDIR /${APOLLO_WHITELABEL_NAME}

RUN echo 'Ansible refuses to read from a world-writeable folder, hence' \
    && chmod -v 700 $(pwd)

COPY requirements.yml requirements.yml

RUN ansible-galaxy install --ignore-errors -r requirements.yml

COPY .zshrc /root/.zshrc

COPY apollo-cli.py /usr/local/bin/apollo

COPY docker-entrypoint.sh /docker-entrypoint.sh

COPY . .

WORKDIR ${APOLLO_SPACES_DIR}

ENTRYPOINT ["/docker-entrypoint.sh"]

SHELL ["/bin/zsh", "-c"]

RUN ["/bin/zsh", "-c", "/usr/local/bin/apollo", "--install-completion", "zsh"]

CMD ["/usr/local/bin/apollo"]

ARG BUILD_DATE

ARG SHIPMATE_CARGO_VERSION

ARG APOLLO_VERSION

ENV APOLLO_VERSION=$SHIPMATE_CARGO_VERSION

LABEL org.label-schema.build-date=$BUILD_DATE
