<script lang="ts">
	import type { NDKUser } from "@nostr-dev-kit/ndk";
	import type { UserProfileType } from "../../../app";
	import UserProfile from "./UserProfile.svelte";
	import { Avatar, Name } from "@kind0/ui-common";

    export let user: NDKUser;
    export let userProfile: UserProfileType | undefined = undefined;
    export let authorUrl: string | undefined = undefined;
    export let spacing = "gap-2";
    export let avatarType: 'circle' | 'square' | undefined = "circle";
    export let avatarSize: 'tiny' | 'small' | 'medium' | 'large' | undefined = "medium";
</script>

<UserProfile {user} bind:userProfile let:fetching bind:authorUrl>
    <a href={authorUrl} class="flex flex-row items-center {spacing} {$$props.class}">
        <Avatar {userProfile} {fetching} size={avatarSize} class={$$props.avatarClass??""} type={avatarType} />

        <Name {userProfile} {fetching} {authorUrl} class={$$props.nameClass??""} />
    </a>
</UserProfile>