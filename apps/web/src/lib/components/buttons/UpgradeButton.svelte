<script lang="ts">
	import BecomeSupporterModal from '$modals/BecomeSupporterModal.svelte';
	import { requiredTiersFor } from "$lib/events/tiers";
	import type { NDKEvent } from "@nostr-dev-kit/ndk";
    import { userTiers } from "$stores/user-view";
	import { LockSimple } from "phosphor-svelte";
	import { openModal } from "svelte-modals";

    export let event: NDKEvent;
    export let text = "Become a fan to unlock";

    const requiredTier = requiredTiersFor(event)[0];
    const author = event.author;

    function upgrade() {
        openModal(BecomeSupporterModal, { user: author, tiers: $userTiers, suggestedTier: requiredTier });
    }
</script>

<button class="button px-4 py-3 {$$props.class??""}" on:click={upgrade}>
    <LockSimple class="w-6 h-6" />
    {text}
</button>