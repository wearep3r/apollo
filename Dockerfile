FROM registry.gitlab.com/peter.saarland/ansible-boilerplate:latest

LABEL maintainer="Fabian Peter <fabian@peter.saarland>"

ENV TERRAFORM_VERSION=0.12.26

ENV TERRAFORM_INVENTORY_VERSION=0.9

ENV APOLLO_WHITELABEL_NAME=apollo

ENV APOLLO_CONFIG_DIR=/root/.${APOLLO_WHITELABEL_NAME}

ENV APOLLO_SPACES_DIR=${APOLLO_CONFIG_DIR}/.spaces

ENV TERM=xterm-256color 

RUN mkdir -p ${APOLLO_CONFIG_DIR} ${APOLLO_SPACES_DIR} /${APOLLO_WHITELABEL_NAME} /root/.ssh /root/.local/share/fonts /root/.config /usr/local/share/fonts /cargo
# silversearcher-ag
RUN apt-get update --allow-releaseinfo-change \
    && apt-get -y --no-install-recommends install zsh less man sudo rsync qrencode python3-jmespath fonts-firacode procps wget fontconfig mosh \
    && sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)" \
    && git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf \
    && ~/.fzf/install --all --key-bindings --completion \
    && curl -fsSL https://starship.rs/install.sh | bash -s -- --yes \
    && pip install jmespath typer[all] anyconfig \
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

RUN curl -fsSL "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip" -o terraform.zip \
    && unzip terraform.zip \
    && rm terraform.zip \
    && chmod +x terraform \
    && mv terraform /usr/local/bin/

WORKDIR /${APOLLO_WHITELABEL_NAME}

COPY requirements.yml requirements.yml

RUN ansible-galaxy install --ignore-errors -r requirements.yml

COPY .zshrc /root/.zshrc

COPY starship.toml /root/.config/starship.toml

#COPY apollo.zsh /usr/local/bin/apollo

COPY apollo.py /usr/local/bin/apollo

COPY docker-entrypoint.sh /docker-entrypoint.sh

COPY motd /etc/motd

COPY . .

WORKDIR ${APOLLO_SPACES_DIR}

ENTRYPOINT ["/docker-entrypoint.sh"]

SHELL ["/bin/zsh", "-c"]

CMD ["/usr/local/bin/apollo"]

ARG BUILD_DATE

ARG SHIPMATE_CARGO_VERSION

ARG APOLLO_VERSION

ENV APOLLO_VERSION=$SHIPMATE_CARGO_VERSION

LABEL org.label-schema.build-date=$BUILD_DATE
