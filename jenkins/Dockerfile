FROM jenkins/jenkins:lts-jdk21

USER root

ARG TERRAFORM_VERSION=1.13.5
ARG TFLINT_VERSION=0.59.1
ARG KUBECTL_VERSION=v1.35.0

RUN apt-get update && \
  apt-get install -y \
  ca-certificates \
  curl \
  git \
  gnupg \
  jq \
  lsb-release \
  python3 \
  python3-pip \
  python3-venv \
  unzip \
  wget && \
  rm -rf /var/lib/apt/lists/*

# Install Terraform
RUN ARCH="$(dpkg --print-architecture)" && \
  case "$ARCH" in \
  amd64) TF_ARCH="amd64" ;; \
  arm64) TF_ARCH="arm64" ;; \
  *) echo "Unsupported architecture: $ARCH" && exit 1 ;; \
  esac && \
  curl -fsSLo /tmp/terraform.zip \
  "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_${TF_ARCH}.zip" && \
  unzip /tmp/terraform.zip -d /usr/local/bin && \
  chmod +x /usr/local/bin/terraform && \
  rm -f /tmp/terraform.zip

# Install AWS CLI v2
RUN ARCH="$(dpkg --print-architecture)" && \
  case "$ARCH" in \
  amd64) AWS_ARCH="x86_64" ;; \
  arm64) AWS_ARCH="aarch64" ;; \
  *) echo "Unsupported architecture: $ARCH" && exit 1 ;; \
  esac && \
  curl -fsSLo /tmp/awscliv2.zip \
  "https://awscli.amazonaws.com/awscli-exe-linux-${AWS_ARCH}.zip" && \
  unzip -q /tmp/awscliv2.zip -d /tmp && \
  /tmp/aws/install && \
  rm -rf /tmp/aws /tmp/awscliv2.zip

# Install kubectl
RUN ARCH="$(dpkg --print-architecture)" && \
  case "$ARCH" in \
  amd64) KUBE_ARCH="amd64" ;; \
  arm64) KUBE_ARCH="arm64" ;; \
  *) echo "Unsupported architecture: $ARCH" && exit 1 ;; \
  esac && \
  curl -fsSLo /usr/local/bin/kubectl \
  "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/${KUBE_ARCH}/kubectl" && \
  chmod +x /usr/local/bin/kubectl

# Install TFLint
RUN ARCH="$(dpkg --print-architecture)" && \
  case "$ARCH" in \
  amd64) TFLINT_ARCH="linux_amd64" ;; \
  arm64) TFLINT_ARCH="linux_arm64" ;; \
  *) echo "Unsupported architecture: $ARCH" && exit 1 ;; \
  esac && \
  curl -fsSLo /tmp/tflint.zip \
  "https://github.com/terraform-linters/tflint/releases/download/v${TFLINT_VERSION}/tflint_${TFLINT_ARCH}.zip" && \
  unzip /tmp/tflint.zip -d /usr/local/bin && \
  chmod +x /usr/local/bin/tflint && \
  rm -f /tmp/tflint.zip

# Install Checkov
RUN python3 -m venv /opt/checkov && \
  /opt/checkov/bin/pip install --no-cache-dir --upgrade pip setuptools wheel && \
  /opt/checkov/bin/pip install --no-cache-dir checkov && \
  ln -s /opt/checkov/bin/checkov /usr/local/bin/checkov
# Install Jenkins plugins
COPY plugins.txt /usr/share/jenkins/ref/plugins.txt

RUN jenkins-plugin-cli \
  --plugin-file /usr/share/jenkins/ref/plugins.txt

RUN mkdir -p /home/jenkins/.aws /home/jenkins/.kube && \
  chown -R jenkins:jenkins /home/jenkins

USER jenkins
