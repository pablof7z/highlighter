<script lang="ts">
	import Avatar from '$components/User/Avatar.svelte';
import Name from '$components/User/Name.svelte';
import { ndk } from "$stores/ndk.js";
	import type { Hexpubkey } from "@nostr-dev-kit/ndk";
	import { slide } from "svelte/transition";
    import UserProfile from "$components/User/UserProfile.svelte";

    export let pubkey: Hexpubkey;
    export let selectedId: string;
    let id = pubkey;

    const user = $ndk.getUser({ pubkey });

    let userProfile: UserProfile | undefined = undefined;

    $: id = userProfile?.nip05 || pubkey;
</script>

<UserProfile {user} bind:userProfile let:fetching>
    <a
        href="?id={id}"
        class="justify-between items-center gap-2 flex w-full p-3"
        class:active={selectedId === id}
        class:list-item--active={selectedId === id}
        transition:slide
    >
        <div class="flex flex-row gap-2 items-center">
            <Avatar {userProfile} {fetching} class="w-11 h-11 mask mask-squircle rounded-none" />
            <div class="flex flex-col items-start gap-1">
                <span class="truncate name">
                    <Name
                        {userProfile}
                        {fetching}
                        class="text-right text-white text-[15px] font-medium"
                    />
                </span>
                <div class="truncate text-xs font-light text-neutral-500">
                    {userProfile?.about??""}
                </div>
            </div>
        </div>
    </a>
</UserProfile>

<style lang="postcss">
    .active {
        @apply w-full;
        @apply text-white p-3;
    }
</style>
