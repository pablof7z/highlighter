<script lang="ts">
	import { Avatar, Name, ndk } from "@kind0/ui-common";
	import type { Hexpubkey } from "@nostr-dev-kit/ndk";
	import { slide } from "svelte/transition";
    import UserProfile from "$components/User/UserProfile.svelte";

    export let pubkey: Hexpubkey;
    export let selectedId: string;
    let id = pubkey;

    const user = $ndk.getUser({ pubkey });

    const randSkeletonWidth = Math.max(Math.floor(Math.random() * 100) + 120, 1900);
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
            <Avatar {userProfile} {fetching} class="w-11 h-11 rounded-full" />
            <span class="truncate name">
                <Name
                    {userProfile}
                    {fetching}
                    class="text-right text-[15px] font-medium"
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

<!--
{#if userProfile !== undefined}
    <a
        {href}
        class="justify-between items-center gap-2 flex w-full"
        class:active={selectedId === pubkey || selectedId === id}
        transition:slide
    >
        <div class="flex flex-row gap-2 items-center">
            <UserProfile {user}>
                <Avatar {userProfile} {fetching} class="w-11 h-11 rounded-full" />
                <span class="truncate text-white name">
                    <Name {userProfile} class="text-right text-[15px] font-medium" />
                </span>
            </UserProfile>
        </div>
    </a>
{:else}
    <a
        {href}
        class="justify-between items-center gap-2 flex w-full"
        class:active={selectedId === pubkey || selectedId === id}
        transition:slide
        >
        <div class="flex flex-row gap-2 items-center w-full">

            <div class="skeleton h-[15px] text-[15px] font-medium" style="width: {randSkeletonWidth}px;" />
        </div>
    </a>
{/if} -->