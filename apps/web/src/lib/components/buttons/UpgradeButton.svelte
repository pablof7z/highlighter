<script lang="ts">
	import currentUser from '$stores/currentUser';
	import SignupModal from '$modals/SignupModal.svelte';
	import BecomeSupporterModal from '$modals/BecomeSupporterModal.svelte';
	import type { NDKEvent } from "@nostr-dev-kit/ndk";
	import { Crown, CrownSimple, LockSimple } from "phosphor-svelte";
	import { openModal } from '$utils/modal';
	import { Button } from '$components/ui/button';

    export let event: NDKEvent;
    export let text = "This is a members-only post. Subscribe to read the full article.";

    const author = event.author;

    function upgrade() {
        if (!$currentUser) {
            openModal(SignupModal, { redirect: window.location.pathname });
        } else {
            openModal(BecomeSupporterModal, { user: author });
        }
    }
</script>

<Button variant="outline" size="lg" class="border-accent hover:bg-background hover:text-foreground font-sans flex flex-col items-center p-4 h-fit {$$props.class??""}" on:click={upgrade}>
    <CrownSimple class="w-6 h-6" weight="fill" />

    {#if $$slots.default}
    {:else}
        <div class="text-lg font-medium">
            This is a members-only post.
        </div>
        <div class="text-foreground/90">
            Subscribe to read the full article.
        </div>
    {/if}
</Button>