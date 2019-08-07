ARG ALPINE_VERSION=3.10.1

FROM library/alpine:${ALPINE_VERSION} AS builder

ARG TERRAFORM_VERSION=0.12.6
ARG TERRAFORM_VERSION_SHA256SUM=6544eb55b3e916affeea0a46fe785329c36de1ba1bdb51ca5239d3567101876f

RUN apk add --update curl zip && \
    curl -sSL --fail https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip \
        -o /tmp/terraform.zip && \
    echo "${TERRAFORM_VERSION_SHA256SUM}  /tmp/terraform.zip" | sha256sum -c - && \
    unzip /tmp/terraform.zip -d /usr/bin && \
    rm /tmp/terraform.zip && \
    apk del curl zip && \
    rm -rf /var/cache/apk/*

FROM library/alpine:${ALPINE_VERSION}

RUN apk add --update ca-certificates && rm -rf /var/cache/apk/*

COPY --from=builder /usr/bin/terraform /usr/bin/terraform

ENTRYPOINT ["/usr/bin/terraform"]
