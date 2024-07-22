<script lang="ts">
	import FollowButton from "$components/buttons/FollowButton.svelte";
	import SubscribeButton from "$components/buttons/SubscribeButton.svelte";
    import * as Footer from "$components/Footer";
	import { Button } from "$components/ui/button";
	import PinModal from "$modals/PinModal.svelte";
	import currentUser from "$stores/currentUser";
	import { openModal } from "$utils/modal";
    import { NDKUser, NDKUserProfile } from "@nostr-dev-kit/ndk";
	import Zap from "$components/Events/Zaps/Zap.svelte";

    export let user: NDKUser;
    export let collapsed = true;
    export let mainView: string;
    export let userProfile: NDKUserProfile | undefined;
    let collapse: () => void;

    let isFollowed: boolean | undefined;
    let isCurrentUser: boolean | undefined;

    $: isCurrentUser = $currentUser?.pubkey === user.pubkey;

    let zapped = false;

    function onZapped() {
        collapse();
        zapped = true;
    }

    let placeholder = "Write";

    $: if (userProfile?.displayName) {
        placeholder = `Write to ${userProfile.displayName}`;
    }
</script>

<Footer.Shell
    bind:collapse
    bind:mainView
    {placeholder}
    let:open
>
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
        {#if mainView === 'zap'}
            <Zap
                {user}
                on:zap={onZapped}
            />
        {:else}
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
        {/if}
    </div>
</Footer.Shell>