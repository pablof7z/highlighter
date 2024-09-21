<script lang="ts">
	import AvatarWithName from "$components/User/AvatarWithName.svelte";
	import { ndk } from "$stores/ndk";
	import { Hexpubkey, NDKUserProfile } from "@nostr-dev-kit/ndk";

    export let items
    export let callback

    let activeIdx = 0

    export function onKeyDown(event) {
        if (event.repeat) {
            return
        }

        switch (event.key) {
            case "ArrowUp":
                activeIdx = (activeIdx + items.length - 1) % items.length
                return true
            case "ArrowDown":
                activeIdx = (activeIdx + 1) % items.length
                return true
            case "Enter":
                let item = items[activeIdx]
                const user = $ndk.getUser({ pubkey: items[activeIdx].pubkey });
                item.npub = user.npub;
                    // .fetchProfile()
                    // .then((profile) => {
                    //     if (profile) item.name = profile.name
                    // })
                    // .finally(() => {
                    //     callback(item)
                    // })
                callback(item)
                return true
        }

        return false
    }
</script>

<ul>
    {#each items as item, i}
        <li class:active={i === activeIdx}>
            <span on:click={() => callback(items[i])}>
                <AvatarWithName pubkey={item.pubkey} avatarSize="xs" />
            </span>
        </li>
    {/each}
</ul>

<style lang="postcss">
    .active {
        @apply bg-secondary text-foreground;
    }

    li {
        cursor: pointer;
        @apply p-2 text-muted-foreground;
    }
</style>