<script lang="ts">
	import type { NDKUser, NDKUserProfile } from "@nostr-dev-kit/ndk";
	import UserProfile from "./UserProfile.svelte";
	import Avatar from '$components/User/Avatar.svelte';
    import Name from '$components/User/Name.svelte';
    import { ndk } from "$stores/ndk.js";

    export let pubkey: string | undefined = undefined;
    export let user: NDKUser | undefined = !pubkey ? undefined : $ndk.getUser({ pubkey });
    export let userProfile: NDKUserProfile | undefined = undefined;
    export let authorUrl: string | undefined = undefined;
    export let spacing = "gap-2";
    export let leadingText = "";
    export let avatarType: 'circle' | 'square' | undefined = "circle";
    export let avatarSize: 'tiny' | 'small' | 'medium' | 'large' | undefined = "small";
    export let href: string | undefined = undefined;

    function newProfileAfterEose(e: CustomEvent<NDKUserProfile>) {
        userProfile = e.detail;
    }
</script>

{#if !userProfile}
    <UserProfile {user} bind:userProfile let:fetching bind:authorUrl on:newProfileAfterEose={newProfileAfterEose}>
        <a href={href??authorUrl} class="flex flex-row items-center {spacing} {$$props.class}">
            <Avatar {userProfile} {fetching} size={avatarSize} class="flex-none {$$props.avatarClass??""}" type={avatarType} />

            <div class="flex flex-col items-start gap-0">
                <Name {userProfile} {fetching} {authorUrl} class={$$props.nameClass??""} />
                <slot />
            </div>
        </a>
    </UserProfile>
{:else}
    <a href={href??authorUrl} class="flex flex-row items-center {spacing} {$$props.class}">
        <Avatar {user} {pubkey} {userProfile} size={avatarSize} class={$$props.avatarClass??""} type={avatarType} />

        <div class="flex flex-col items-start gap-0">
            <div class="flex flex-row gap-1 truncate flex-nowrap">
                {#if leadingText.length > 0}
                    <span class="opacity-70">{leadingText}</span>
                {/if}
                <Name {user} {pubkey} {userProfile} {authorUrl} class={$$props.nameClass??""} />
            </div>
            <slot />
        </div>
    </a>
{/if}