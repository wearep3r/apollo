FROM registry.gitlab.com/peter.saarland/ansible-boilerplate:latest

LABEL maintainer="Fabian Peter <fabian@peter.saarland>"

ENV TERRAFORM_VERSION=0.12.26

ENV TERRAFORM_INVENTORY_VERSION=0.9

ENV APOLLO_WHITELABEL_NAME=apollo

ENV APOLLO_CONFIG_DIR=/root/.${APOLLO_WHITELABEL_NAME}

ENV APOLLO_SPACES_DIR=${APOLLO_CONFIG_DIR}/.spaces

ENV TERM=xterm-256color 

RUN mkdir -p ${APOLLO_CONFIG_DIR} ${APOLLO_SPACES_DIR} /${APOLLO_WHITELABEL_NAME} /root/.ssh
# silversearcher-ag
RUN apt-get update \
    && apt-get -y --no-install-recommends install zsh less man sudo figlet rsync \
    # && curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add - \
    # && add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian  $(lsb_release -cs) stable" \
    # && apt-get update \
    # && apt-get -y --no-install-recommends install docker-ce-cli \
    # && curl -O -L "https://github.com/grafana/loki/releases/download/v1.5.0/logcli-linux-amd64.zip" -o logcli-linux-amd64.zip \
    # && unzip "logcli-linux-amd64.zip" \
    # && mv logcli-linux-amd64 /usr/local/bin/logcli \
    && sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)" \
    # && curl https://raw.githubusercontent.com/jesseduffield/lazydocker/master/scripts/install_update_linux.sh | bash \
    && git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf \
    && ~/.fzf/install --all --key-bindings --completion \
    && git clone https://github.com/wfxr/forgit ~/.forgit \
    && git clone https://github.com/dracula/zsh.git ~/dracula-zsh \
    && mkdir -p ~/.oh-my-zsh/themes \
    && ln -s ~/dracula-zsh/dracula.zsh-theme ~/.oh-my-zsh/themes/dracula.zsh-theme \
    && git clone https://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/plugins/zsh-autosuggestions \
    && git clone https://github.com/zsh-users/zsh-completions ~/.oh-my-zsh/plugins/zsh-completions \
    && git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.oh-my-zsh/plugins/zsh-syntax-highlighting \
    && git clone https://github.com/lincheney/fzf-tab-completion.git ~/.oh-my-zsh/plugins/fzf-tab-completion \
    && rm -rf /var/lib/apt/lists/* \
    && chsh -s /bin/zsh

RUN curl -fsSL "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip" -o terraform.zip \
    && unzip terraform.zip \
    && rm terraform.zip \
    && chmod +x terraform \
    && mv terraform /usr/local/bin/

WORKDIR /${APOLLO_WHITELABEL_NAME}

COPY requirements.yml requirements.yml

RUN ansible-galaxy install --ignore-errors -r requirements.yml

COPY .zshrc /root/.zshrc

COPY apollo.zsh /usr/local/bin/apollo

COPY docker-entrypoint.sh /docker-entrypoint.sh

COPY motd /etc/motd

COPY . .

WORKDIR ${APOLLO_SPACES_DIR}

ENTRYPOINT ["/docker-entrypoint.sh"]

SHELL ["/bin/zsh", "-c"]

CMD ["/bin/zsh"]

ARG BUILD_DATE

ARG SHIPMATE_CARGO_VERSION

ARG APOLLO_VERSION

ENV APOLLO_VERSION=$SHIPMATE_CARGO_VERSION

LABEL org.label-schema.build-date=$BUILD_DATE
