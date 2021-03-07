#!/bin/bash
set -e

# Configure Ghost to listen on all ips and not prompt for additional
#   configuration, also configure database and email settings
gosu node ghost config --ip 0.0.0.0 --port 2368 --no-prompt --url $URL \
    --db $DB --dbhost $DBHOST --dbuser $DBUSER --dbpass $DBPASS \
    --dbname $DBNAME --mail SMTP --mailservice SES --mailuser $MAILUSER \
    --mailpass $MAILPASS --mailhost $MAILHOST --mailport $MAILPORT
# Configure content-path
gosu node ghost config paths.contentPath "$GHOST_CONTENT"

# allow the container to be started with `--user`
#if [[ "$*" == node*current/index.js* ]] && [ "$(id -u)" = '0' ]; then
#	find "$GHOST_CONTENT" \! -user node -exec chown node '{}' +
#	exec gosu node "$BASH_SOURCE" "$@"
#fi

if [[ "$*" == node*current/index.js* ]]; then
	baseDir="$GHOST_INSTALL/content.orig"
	for src in "$baseDir"/*/ "$baseDir"/themes/*; do
		src="${src%/}"
		target="$GHOST_CONTENT/${src#$baseDir/}"
		mkdir -p "$(dirname "$target")"
		if [ ! -e "$target" ]; then
			tar -cC "$(dirname "$src")" "$(basename "$src")" | tar -xC "$(dirname "$target")"
		fi
	done
fi

exec "$@"

