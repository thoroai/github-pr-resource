FROM alpine:3.8 as cryptbuilder
ADD scripts/install_git_crypt.sh install_git_crypt.sh
RUN ./install_git_crypt.sh && rm ./install_git_crypt.sh

FROM alpine:3.8 as resource
RUN apk add --update --no-cache \
    git \
    openssh

FROM golang:1.13 as gobuilder
ADD . /go/src/github.com/telia-oss/github-pr-resource
WORKDIR /go/src/github.com/telia-oss/github-pr-resource
RUN curl -sL https://taskfile.dev/install.sh | sh
RUN ./bin/task build

FROM resource

COPY scripts/askpass.sh /usr/local/bin/askpass.sh
COPY --from=cryptbuilder /usr/local/bin/git-crypt /usr/local/bin/git-crypt
COPY --from=gobuilder /go/src/github.com/telia-oss/github-pr-resource/build /opt/resource

RUN chmod +x /opt/resource/*

LABEL MAINTAINER=carnegierobotics
