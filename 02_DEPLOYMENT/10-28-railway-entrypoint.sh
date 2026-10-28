#!/bin/sh
set -eu

if [ ! -d "${DATA_FOLDER:-/data}" ]; then
  echo "ERROR: Vaultwarden data directory is unavailable." >&2
  exit 1
fi

mkdir -p "${DATA_FOLDER:-/data}/templates/scss"
install -m 0644 \
  /opt/digivista/user.vaultwarden.scss.hbs \
  "${DATA_FOLDER:-/data}/templates/scss/user.vaultwarden.scss.hbs"

# Railway supplies PORT dynamically. Vaultwarden/Rocket uses ROCKET_PORT.
export ROCKET_PORT="${PORT:-${ROCKET_PORT:-80}}"
export ROCKET_ADDRESS="${ROCKET_ADDRESS:-0.0.0.0}"

exec /start.sh
