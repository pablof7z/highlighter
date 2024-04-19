<script lang="ts">
	import type { NDKUser } from "@nostr-dev-kit/ndk";
	import type { UserProfileType } from "../../../app";
	import UserProfile from "./UserProfile.svelte";
	import { Avatar, Name, ndk } from "@kind0/ui-common";

    export let pubkey: string | undefined = undefined;
    export let user: NDKUser | undefined = !pubkey ? undefined : $ndk.getUser({ pubkey });
    export let userProfile: UserProfileType | undefined = undefined;
    export let authorUrl: string | undefined = undefined;
    export let spacing = "gap-2";
    export let avatarType: 'circle' | 'square' | undefined = "circle";
    export let avatarSize: 'tiny' | 'small' | 'medium' | 'large' | undefined = "medium";

    function newProfileAfterEose(e: CustomEvent<UserProfileType>) {
        console.log('newProfileAfterEose');
        userProfile = e.detail;
    }
</script>

{#if !userProfile}
    <UserProfile {user} bind:userProfile let:fetching bind:authorUrl on:newProfileAfterEose={newProfileAfterEose}>
        <a href={authorUrl} class="flex flex-row items-center {spacing} {$$props.class}">
            <Avatar {userProfile} {fetching} size={avatarSize} class="flex-none {$$props.avatarClass??""}" type={avatarType} />

            <div class="flex flex-col items-start gap-0">
                <Name {userProfile} {fetching} {authorUrl} class={$$props.nameClass??""} />
                <slot />
            </div>
        </a>
    </UserProfile>
{:else}
    <a href={authorUrl} class="flex flex-row items-center {spacing} {$$props.class}">
        <Avatar {user} {pubkey} {userProfile} size={avatarSize} class={$$props.avatarClass??""} type={avatarType} />

        <div class="flex flex-col items-start gap-0">
            <Name {user} {pubkey} {userProfile} {authorUrl} class={$$props.nameClass??""} />
            <slot />
        </div>
    </a>
{/if}