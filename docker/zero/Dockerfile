FROM python:3.8.2-buster
LABEL maintainer="Fabian Peter <fabian@peter.saarland>"

ARG TERRAFORM_VERSION=0.12.20
ARG TERRAFORM_INVENTORY_VERSION=0.9
ARG KOMPOSE_VERSION=v1.21.0

USER root

RUN apt update && apt install -y --no-install-recommends \
    git \
    curl \
    httpie \
    tar \
    unzip \
    nano \
    openssh-client \
    build-essential \
    libffi-dev \
    libssl1.0 \
    python3-dev \
    && rm -rf /var/lib/apt/lists/* \
    && pip install --no-cache-dir \
    ansible \
    hcloud \
    jsondiff \
    docker \
    ansible-lint \
    docker-compose \
    molecule[lint] \
    # Terraform
    && curl -fsSL "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip" -o terraform.zip \
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
    # minio client
    && curl -fsSL "https://dl.min.io/client/mc/release/linux-amd64/mc" -o /usr/local/bin/mc \
    && chmod +x /usr/local/bin/mc \
    # Kompose
    && curl -L "https://github.com/kubernetes/kompose/releases/download/${KOMPOSE_VERSION}/kompose-linux-amd64" -o /usr/local/bin/kompose \
    && chmod +x /usr/local/bin/kompose \
    # IBM Cloud TF Provider
    && mkdir -p $HOME/.terraform.d/plugins \
    && cd $HOME/.terraform.d/plugins \
    && curl -fsSL "https://github.com/IBM-Cloud/terraform-provider-ibm/releases/download/v1.3.0/linux_amd64.zip" -o ./terraform-provider-ibm.zip \
    && unzip terraform-provider-ibm.zip \
    && rm terraform-provider-ibm.zip

RUN mkdir /infrastructure \
    && mkdir /root/.ssh

WORKDIR /infrastructure/terraform
RUN terraform init
WORKDIR /infrastructure
COPY . .
RUN echo 'Ansible refuses to read from a world-writeable folder, hence' \
    && chmod -v 700 $(pwd) \
    && ansible-galaxy install --ignore-errors -r requirements.yml \
    && chmod +x docker-entrypoint.sh

ENTRYPOINT ["./docker-entrypoint.sh"]
CMD ["/bin/bash"]
ARG BUILD_DATE
LABEL org.label-schema.build-date=$BUILD_DATE
