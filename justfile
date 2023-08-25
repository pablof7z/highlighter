LOCKFILE := "package-lock.json"

build:
    turbo build
renew:
    if [ -d {{LOCKFILE}} ]; then \
        rm {{LOCKFILE}}; \
    fi \
    && find . -name 'node_modules' -type d -prune -print -exec rm -rf '{}' \; \
    && npm i