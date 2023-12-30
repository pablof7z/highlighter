<script lang="ts">
	import type { NDKEvent } from "@nostr-dev-kit/ndk";
	import ReactButton from "./ReactButton.svelte";
	import BoostButton from "./BoostButton.svelte";
    import { createEventDispatcher } from "svelte";
	import { ChatCircle } from "phosphor-svelte";

    const dispatch = createEventDispatcher();

    export let event: NDKEvent;
</script>

<div class="justify-start items-start gap-3 inline-flex">
    <ReactButton {event} />

    <button class="w-7 h-7 relative" on:click={() => dispatch("comment")}>
        <ChatCircle class="w-7 h-7" />
    </button>

    <BoostButton {event} />
</div>