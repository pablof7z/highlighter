LOCKFILE := "pnpm-lock.yaml"

branches:
    @echo "Current branch: `git branch --show-current`" \
        && if [[ -n $(git status --porcelain) ]]; then \
            git status --porcelain; \
        fi
    @echo "@packages branch: `cd packages && git branch --show-current`" \
        && cd packages && if [[ -n $(git status --porcelain) ]]; then \
            git status --porcelain; \
        fi
    @echo "packages/ndk branch: `cd packages/ndk && git branch --show-current`" \
        && cd packages/ndk && if [[ -n $(git status --porcelain) ]]; then \
            git status --porcelain; \
        fi

update:
    git submodule update --recursive --remote
    cd packages && git checkout master && git pull

build:
    turbo build
renew:
    if [ -d {{LOCKFILE}} ]; then \
        rm {{LOCKFILE}}; \
    fi \
    && find . -name 'node_modules' -type d -prune -print -exec rm -rf '{}' \; \
    && pnpm i

compile-ndk:
    ./ndk_compile.sh