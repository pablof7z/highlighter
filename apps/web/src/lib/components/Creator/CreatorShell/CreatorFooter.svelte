<script lang="ts">
	import FollowButton from "$components/buttons/FollowButton.svelte";
	import SubscribeButton from "$components/buttons/SubscribeButton.svelte";
    import FooterShell from "$components/PageElements/Mobile/FooterShell.svelte";
	import { Button } from "$components/ui/button";
	import PinModal from "$modals/PinModal.svelte";
	import currentUser from "$stores/currentUser";
	import { openModal } from "$utils/modal";
    import { NDKUser } from "@nostr-dev-kit/ndk";

    export let user: NDKUser;
    export let collapsed = true;

    let isFollowed: boolean | undefined;
    let isCurrentUser: boolean | undefined;

    $: isCurrentUser = $currentUser?.pubkey === user.pubkey;
</script>

<FooterShell bind:collapsed>
    {#if collapsed}
        {#if !isCurrentUser}
            {#if !isFollowed}
                <FollowButton bind:isFollowed {user} />
            {:else}
                <SubscribeButton {user} />
            {/if}
        {/if}
    {/if}

    <div class="flex flex-col items-stretch gap-4 w-full" slot="main">
        {#if !isCurrentUser}
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
        {:else}
            <Button
                variant="outline"
                class="flex-none w-full"
                on:click={() => openModal(PinModal)}
            >
                Pin
            </Button>
        {/if}
    </div>
</FooterShell>