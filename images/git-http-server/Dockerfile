FROM node:18-alpine

RUN apk add --no-cache tini git \
    && npm install -g git-http-server \
    && adduser -D -g git git \
    && git config --system user.email "gitserver@git.com"  \
    && git config --system user.name "Git Server" \
    && git config --system init.defaultBranch "main"


USER git
WORKDIR /home/git

RUN mkdir /tmp/repository/ \
    && cd /tmp/repository \
    && touch file.txt \
    && git init . \
    && git add --all \
    && git commit -m "initial commit" \
    && git clone --bare /tmp/repository/ /home/git/repository.git &>/dev/null


ENTRYPOINT ["tini", "--", "git-http-server", "-p", "80", "/home/git"]
