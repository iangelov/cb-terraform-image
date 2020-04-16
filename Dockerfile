ARG ALPINE_VERSION

FROM library/alpine:${ALPINE_VERSION} AS builder

ARG TERRAFORM_VERSION
ARG TERRAFORM_VERSION_SHA256SUM
ARG CONFTEST_VERSION

RUN apk add --update curl zip && \
    curl -sSL --fail https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip \
        -o /tmp/terraform.zip && \
    echo "${TERRAFORM_VERSION_SHA256SUM}  /tmp/terraform.zip" | sha256sum -c - && \
    unzip /tmp/terraform.zip -d /usr/bin && \
    rm /tmp/terraform.zip && \
    curl -sSL --fail https://github.com/instrumenta/conftest/releases/download/v${CONFTEST_VERSION}/conftest_${CONFTEST_VERSION}_Linux_x86_64.tar.gz \
    -o /tmp/conftest.tar.gz && \
    tar -C /usr/bin -zxf /tmp/conftest.tar.gz conftest

FROM library/alpine:${ALPINE_VERSION}

RUN apk add --update ca-certificates && rm -rf /var/cache/apk/*

COPY --from=builder /usr/bin/terraform /usr/bin/terraform
COPY --from=builder /usr/bin/conftest /usr/bin/conftest

USER 1000

ENTRYPOINT ["/usr/bin/terraform"]
