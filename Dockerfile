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
  DEFAULT_SCRIPT=start \
  GIT_REPO="" \
  LANG=C.UTF-8 \
  NODE_ENV=production \
  NPM=npm

COPY buildenv/entrypoint.sh /usr/local/sbin/entrypoint
COPY buildenv/buildenv.sh /usr/local/bin/buildenv

COPY buildenv/buildenv.conf /etc/
COPY buildenv.d/ /etc/buildenv.d/

RUN sed -i 's/^#DOTCMDS=.*/DOTCMDS=setup/' /etc/buildenv.conf

ENTRYPOINT ["/usr/local/sbin/entrypoint"]
CMD ["/bin/bash"]
