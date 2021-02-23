# https://docs.ghost.org/faq/node-versions/
# https://github.com/nodejs/LTS
# https://github.com/TryGhost/Ghost/blob/3.3.0/package.json#L38
FROM node:12-buster-slim

# grab gosu for easy step-down from root
# https://github.com/tianon/gosu/releases
ENV GOSU_VERSION 1.12
RUN set -eux; \
# save list of currently installed packages for later so we can clean up
	savedAptMark="$(apt-mark showmanual)"; \
	apt-get update; \
	apt-get install -y --no-install-recommends ca-certificates dirmngr gnupg wget; \
	rm -rf /var/lib/apt/lists/*; \
	\
	dpkgArch="$(dpkg --print-architecture | awk -F- '{ print $NF }')"; \
	wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch"; \
	wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch.asc"; \
	\
# verify the signature
	export GNUPGHOME="$(mktemp -d)"; \
	gpg --batch --keyserver hkps://keys.openpgp.org --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4; \
	gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu; \
	command -v gpgconf && gpgconf --kill all || :; \
	rm -rf "$GNUPGHOME" /usr/local/bin/gosu.asc; \
	\
# clean up fetch dependencies
	apt-mark auto '.*' > /dev/null; \
	[ -z "$savedAptMark" ] || apt-mark manual $savedAptMark > /dev/null; \
	apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false; \
	\
	chmod +x /usr/local/bin/gosu; \
# verify that the binary works
	gosu --version; \
	gosu nobody true

ENV NODE_ENV production

ENV GHOST_CLI_VERSION 1.15.3
RUN set -eux; \
	npm install -g "ghost-cli@$GHOST_CLI_VERSION"; \
	npm cache clean --force

ENV GHOST_INSTALL /var/lib/ghost
ENV GHOST_CONTENT /var/lib/ghost/content

ENV GHOST_VERSION 3.40.5

RUN set -eux; \
    mkdir -p "$GHOST_INSTALL"; \
    chown node:node "$GHOST_INSTALL"; \
    \
# install Ghost
    gosu node ghost install "$GHOST_VERSION" --no-prompt --db sqlite3 --no-stack \
  	--no-setup --dir "$GHOST_INSTALL"; \
    \
    cd "$GHOST_INSTALL"; \
    \
# make a config.json symlink for NODE_ENV=development (and sanity check that it's correct)
    gosu node ln -s config.production.json "$GHOST_INSTALL/config.development.json"; \
    readlink -f "$GHOST_INSTALL/config.development.json"; \
    \
# need to save initial content for pre-seeding empty volumes
    mv "$GHOST_CONTENT" "$GHOST_INSTALL/content.orig"; \
    mkdir -p "$GHOST_CONTENT"; \
    chown node:node "$GHOST_CONTENT"; \
    chmod 1777 "$GHOST_CONTENT"; \
    \
# clean up
    gosu node yarn cache clean; \
    gosu node npm cache clean --force; \
    npm cache clean --force; \
    rm -rv /tmp/yarn* /tmp/v8*

WORKDIR $GHOST_INSTALL
VOLUME $GHOST_CONTENT

COPY docker-entrypoint.sh /usr/local/bin
ENTRYPOINT ["docker-entrypoint.sh"]

EXPOSE 2368
CMD ["node", "current/index.js"]

