<script lang="ts">
	import { Avatar, Name, ndk } from "@kind0/ui-common";
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
        class="justify-between items-center gap-2 flex w-full"
        class:active={selectedId === id}
        transition:slide
    >
        <div class="flex flex-row gap-2 items-center">
            <Avatar {userProfile} {fetching} class="w-11 h-11 mask mask-squircle rounded-none" />
            <span class="truncate name">
                <Name
                    {userProfile}
                    {fetching}
                    class="text-right text-[15px] font-normal"
                />
            </span>
        </div>
    </a>
</UserProfile>

<style lang="postcss">
    .active {
        @apply text-white;
    }
</style>
