FROM ubuntu:latest@sha256:72297848456d5d37d1262630108ab308d3e9ec7ed1c3286a32fe09856619a782

ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update \
        && apt-get install -y rpm gnupg2 curl \
        && apt-get clean \
        && rm -rf /var/lib/apt/lists/*

ENV HOME=/home/graviteeio
RUN addgroup --gid 1001 graviteeio \
	&& adduser --home "${HOME}" --uid 1001 --gid 1001 --disabled-password graviteeio

RUN mkdir /rpms \
    && chown -R graviteeio:graviteeio /rpms

COPY --chown=graviteeio:graviteeio --chmod=555 utils.sh "${HOME}/utils.sh"
RUN echo "\nsource \"${HOME}/utils.sh\"\n" >> "${HOME}/.bashrc"
COPY --chown=graviteeio:graviteeio --chmod=555 entrypoint.sh "/usr/bin/entrypoint.sh"

USER graviteeio
WORKDIR /rpms
ENTRYPOINT ["/usr/bin/entrypoint.sh"]
