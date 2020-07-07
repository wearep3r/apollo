FROM registry.gitlab.com/peter.saarland/ansible-boilerplate:latest

LABEL maintainer="Fabian Peter <fabian@peter.saarland>"

ENV TERRAFORM_VERSION=0.12.26

ENV TERRAFORM_INVENTORY_VERSION=0.9

ENV APOLLO_WHITELABEL_NAME=apollo

ENV ENVIRONMENT_DIR=/root/.${APOLLO_WHITELABEL_NAME}/.environments/${APOLLO_WHITELABEL_NAME}

RUN mkdir -p /root/.apollo/.spaces ${ENVIRONMENT_DIR} /root/.ssh /apollo

RUN apt update && apt -y --no-install-recommends install zsh less ruby man silversearcher-ag \
    && gem install lolcat  \
    && rm -rf /var/lib/apt/lists/* \
    && sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)" \
    && git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf \
    && ~/.fzf/install --all --key-bindings --completion \
    && git clone https://github.com/wfxr/forgit ~/.forgit \
    && git clone https://github.com/dracula/zsh.git ~/dracula-zsh \
    && mkdir -p ~/.oh-my-zsh/themes \
    && ln -s ~/dracula-zsh/dracula.zsh-theme ~/.oh-my-zsh/themes/dracula.zsh-theme \
    && git clone https://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/plugins/zsh-autosuggestions \
    && git clone https://github.com/zsh-users/zsh-completions ~/.oh-my-zsh/plugins/zsh-completions \
    && git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.oh-my-zsh/plugins/zsh-syntax-highlighting \
    && git clone https://github.com/lincheney/fzf-tab-completion.git ~/.oh-my-zsh/plugins/fzf-tab-completion

RUN curl -fsSL "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip" -o terraform.zip \
    && unzip terraform.zip \
    && rm terraform.zip \
    && chmod +x terraform \
    && mv terraform /usr/local/bin/ \
    # terraform-invenvory
    && curl -fsSL "https://github.com/adammck/terraform-inventory/releases/download/v${TERRAFORM_INVENTORY_VERSION}/terraform-inventory_${TERRAFORM_INVENTORY_VERSION}_linux_amd64.zip" -o terraform-inventory.zip \
    && unzip terraform-inventory.zip \
    && rm terraform-inventory.zip \
    && chmod +x terraform-inventory \
    && mv terraform-inventory /usr/local/bin/ \
    # IBM Cloud TF Provider
    && mkdir -p $HOME/.terraform.d/plugins \
    && cd $HOME/.terraform.d/plugins \
    && curl -fsSL "https://github.com/IBM-Cloud/terraform-provider-ibm/releases/download/v1.3.0/linux_amd64.zip" -o ./terraform-provider-ibm.zip \
    && unzip terraform-provider-ibm.zip \
    && rm terraform-provider-ibm.zip

WORKDIR /${APOLLO_WHITELABEL_NAME}

COPY requirements.yml requirements.yml

RUN ansible-galaxy install --ignore-errors -r requirements.yml

COPY roles/apollo-core/templates/zshrc.j2 /root/.zshrc

COPY . .

ENTRYPOINT ["./docker-entrypoint.sh"]

CMD ["/bin/zsh"]

ARG BUILD_DATE

LABEL org.label-schema.build-date=$BUILD_DATE
