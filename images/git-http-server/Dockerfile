FROM node:alpine

RUN apk add --no-cache tini git \
    && yarn global add git-http-server \
    && adduser -D -g git git

USER git
WORKDIR /home/git

RUN git init --bare repository.git --initial-branch=main

ENTRYPOINT ["tini", "--", "git-http-server", "-p", "80", "/home/git"]
