FROM registry.gitlab.com/peter.saarland/ansible-boilerplate:latest

LABEL maintainer="Fabian Peter <fabian@peter.saarland>"

ENV TERRAFORM_VERSION=0.12.26

ENV TERRAFORM_INVENTORY_VERSION=0.9

ENV ENVIRONMENT_DIR=/root/.if0/.environments/zero

RUN mkdir -p ${ENVIRONMENT_DIR} /root/.ssh /zero

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

WORKDIR /zero

COPY requirements.yml requirements.yml

RUN ansible-galaxy install --ignore-errors -r requirements.yml

COPY . .

RUN echo 'export PS1="[\$IF0_ENVIRONMENT] \W # "' >> /root/.bashrc

ENTRYPOINT ["./docker-entrypoint.sh"]

CMD ["/bin/bash"]

ARG BUILD_DATE

LABEL org.label-schema.build-date=$BUILD_DATE
