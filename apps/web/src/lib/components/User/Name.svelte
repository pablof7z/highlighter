<script lang="ts">
    import { ndk } from "$stores/ndk.js";

    import {Name} from '@nostr-dev-kit/ndk-svelte-components';
    import type { NDKUser, NDKUserProfile } from '@nostr-dev-kit/ndk';
    import { onMount } from "svelte";

    export let pubkey: string | undefined = undefined;
    export let user: NDKUser | undefined = undefined;
    export let userProfile: NDKUserProfile | undefined = undefined;
    export let npubMaxLength: number | undefined = 12;

    let timedout = false;

    onMount(() => {
        setTimeout(() => {
            timedout = true;
        }, 1500);
    });

    /**
     * Flag when the fetching is being done in a higher component
     **/
    export let fetching: boolean | undefined = undefined;

    const randSkeletonWidth = Math.max(Math.floor(Math.random() * 100) + 120, 190);

    const defaultLoadingClass = "skeleton h-[15px]";
    const defaultLoadingStyle = `width: ${randSkeletonWidth}px; height: 15px;`;
</script>

{#if !userProfile && fetching && !timedout}
    <div
        style={$$props.loadingStyle ? $$props.loadingStyle : defaultLoadingStyle}
        class={$$props.loadingClass ? $$props.loadingClass : defaultLoadingClass}
    />
{:else if userProfile || user || pubkey}
    <Name
        ndk={$ndk}
        {pubkey}
        {npubMaxLength}
        {user}
        {userProfile}
        class={$$props.class || ``}
        on:click
    />
{/if}