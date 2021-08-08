ARG tag=latest
FROM node:${tag}

RUN \
  apt-get update \
  && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    git \
    gosu \
    sudo \
    wait-for-it \
  && rm -rf /var/lib/apt/lists/*

RUN \
  usermod -l builder -d /home/builder node \
  && groupmod --new-name builder node \
  && mv /home/node /home/builder \
  && echo "builder ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

USER builder
RUN \
  echo '. <(buildenv init)' >> ~/.bashrc \
  && git config --global user.email "builder@npm" \
  && git config --global user.name "npm builder"

USER root
WORKDIR /home/builder

ENV \
  GIT_REPO="" \
  LANG=C.UTF-8 \
  NPM=npm \
  SCRIPT_BUILD=build \
  SCRIPT_START=start

COPY buildenv/entrypoint.sh /buildenv-entrypoint.sh
COPY buildenv/buildenv.sh /usr/local/bin/buildenv

COPY buildenv/buildenv.conf /etc/
COPY buildenv.d/ /etc/buildenv.d/

RUN sed -i 's/^#DOTCMDS=.*/DOTCMDS=setup/' /etc/buildenv.conf

ENTRYPOINT ["/buildenv-entrypoint.sh"]
CMD ["/bin/bash"]
