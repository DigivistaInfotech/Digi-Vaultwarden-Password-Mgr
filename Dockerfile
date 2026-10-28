FROM docker.io/vaultwarden/server@sha256:094b5689ed81549bd293418395c7cf495ae9d960fc2d4928cef2083ef913d912

USER root

COPY 04_ASSETS/08-30-digivista-phase2-branding.scss /opt/digivista/user.vaultwarden.scss.hbs
COPY 04_ASSETS/DigiVista_Logo.png /web-vault/digivista-assets/DigiVista_Logo.png
COPY 04_ASSETS/08-30-open-source-notices.html /web-vault/open-source-notices/index.html
COPY 05_REFERENCE/08-30-Vaultwarden-AGPL-3.0-LICENSE.txt /web-vault/licenses/08-30-Vaultwarden-AGPL-3.0-LICENSE.txt
COPY 02_DEPLOYMENT/10-28-railway-entrypoint.sh /opt/digivista/railway-entrypoint.sh

RUN chmod 0755 /opt/digivista/railway-entrypoint.sh \
    && chmod 0644 /opt/digivista/user.vaultwarden.scss.hbs \
       /web-vault/digivista-assets/DigiVista_Logo.png \
       /web-vault/open-source-notices/index.html \
       /web-vault/licenses/08-30-Vaultwarden-AGPL-3.0-LICENSE.txt

ENV DATA_FOLDER=/data \
    SIGNUPS_ALLOWED=false \
    INVITATIONS_ALLOWED=true \
    SHOW_PASSWORD_HINT=false \
    LOG_LEVEL=warn \
    EXTENDED_LOGGING=false

ENTRYPOINT ["/opt/digivista/railway-entrypoint.sh"]
