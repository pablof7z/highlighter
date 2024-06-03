<script lang="ts">
	import currentUser from '$stores/currentUser';
	import SignupModal from '$modals/SignupModal.svelte';
	import BecomeSupporterModal from '$modals/BecomeSupporterModal.svelte';
	import type { NDKEvent } from "@nostr-dev-kit/ndk";
	import { LockSimple } from "phosphor-svelte";
	import { openModal } from '$utils/modal';

    export let event: NDKEvent;
    export let text = "Get a backstage pass";

    const author = event.author;

    function upgrade() {
        if (!$currentUser) {
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