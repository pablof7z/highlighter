<script lang="ts">
	import FollowButton from "$components/buttons/FollowButton.svelte";
	import SubscribeButton from "$components/buttons/SubscribeButton.svelte";
import FooterShell from "$components/PageElements/Mobile/FooterShell.svelte";
	import { Button } from "$components/ui/button";
	import { userFollows } from "$stores/session";
    import { NDKUser } from "@nostr-dev-kit/ndk";
	import { Plus } from "phosphor-svelte";

    export let user: NDKUser;
    export let collapsed = true;

    let isFollowed: boolean | undefined;
</script>

<FooterShell bind:collapsed>
    {#if collapsed}
        {#if !isFollowed}
            <FollowButton bind:isFollowed {user} />
        {:else}
            <SubscribeButton {user} />
        {/if}
    {/if}

    <div class="flex flex-col items-stretch gap-4 w-full" slot="main">
        <Button
            variant="outline"
            class="flex-none w-full text-red-500"
            on:click={() => {
                collapsed = false;
            }}
        >
            Mute
        </Button>
        
        <FollowButton bind:isFollowed {user} class="w-full" />
    </div>
</FooterShell>