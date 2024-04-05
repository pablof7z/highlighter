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

deploy:
	rsync -avP -l -t --exclude build --exclude node_modules --exclude .svelte-kit --exclude highlighter.db ./apps/web/ kind0:/home/pablo/projects/highlighter/apps/web
	rsync -avP -l -t --exclude build --exclude node_modules --exclude .svelte-kit --exclude highlighter.db ./packages/ kind0:/home/pablo/projects/highlighter/packages

deploy-old:
#	rsync -avP -l -t --exclude nsecbunker.json --exclude dist --exclude db --exclude nostdress/nostdress --exclude relay/relay29 --exclude .env --exclude .svelte-kit --exclude node_modules --exclude build /Users/pablofernandez/work/projects/highlighter/ kind0:/home/pablo/projects/highlighter

