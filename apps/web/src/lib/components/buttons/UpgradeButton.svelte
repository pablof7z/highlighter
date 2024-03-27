<script lang="ts">
	import SignupModal from '$modals/SignupModal.svelte';
	import BecomeSupporterModal from '$modals/BecomeSupporterModal.svelte';
	import { requiredTiersFor } from "$lib/events/tiers";
	import type { NDKEvent } from "@nostr-dev-kit/ndk";
	import { LockSimple } from "phosphor-svelte";
	import { openModal } from "svelte-modals";
    import { user } from "@kind0/ui-common";

    export let event: NDKEvent;
    export let text = "Get a backstage pass";

    const requiredTier = requiredTiersFor(event)[0];
    const author = event.author;

    function upgrade() {
        if (!$user) {
            openModal(SignupModal, { redirect: window.location.pathname });
        } else {
            openModal(BecomeSupporterModal, { user: author });
        }
    }
</script>

<button class="button px-4 py-3 {$$props.class??""}" on:click={upgrade}>
    <LockSimple class="w-6 h-6" />
    {text}
</button>