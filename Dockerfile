ARG ALPINE_VERSION=3.10.1

FROM library/alpine:${ALPINE_VERSION} AS builder

ARG TERRAFORM_VERSION=0.12.6
ARG TERRAFORM_VERSION_SHA256SUM=6544eb55b3e916affeea0a46fe785329c36de1ba1bdb51ca5239d3567101876f
ARG CONFTEST_VERSION=0.11.0

RUN apk add --update curl zip && \
    curl -sSL --fail https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip \
        -o /tmp/terraform.zip && \
    echo "${TERRAFORM_VERSION_SHA256SUM}  /tmp/terraform.zip" | sha256sum -c - && \
    unzip /tmp/terraform.zip -d /usr/bin && \
    rm /tmp/terraform.zip && \
    curl -sSL --fail https://github.com/instrumenta/conftest/releases/download/v${CONFTEST_VERSION}/conftest_${CONFTEST_VERSION}_Linux_x86_64.tar.gz \
    -o /tmp/conftest.tar.gz && \
    tar -C /usr/local/bin -zxf /tmp/conftest.tar.gz conftest

FROM library/alpine:${ALPINE_VERSION}

RUN apk add --update ca-certificates && rm -rf /var/cache/apk/*

COPY --from=builder /usr/bin/terraform /usr/bin/terraform
COPY --from=builder /usr/bin/conftest /usr/bin/conftest

ENTRYPOINT ["/usr/bin/terraform"]
