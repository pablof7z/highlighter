<script lang="ts">
	import ModalShell from "$components/ModalShell.svelte";
	import { NavigationOption } from '../../app';
	import { closeModal } from 'svelte-modals';
	import Tts from "$components/Actions/TTS/TTS.svelte";
	import { NDKEvent } from "@nostr-dev-kit/ndk";

    export let event: NDKEvent;

    let actionButtons: NavigationOption[] = [];

    $: actionButtons = [
        { name: "Request text-to-speech", fn: () => forceSend = true }
    ]

    let forceSend = false;
    
</script>

<ModalShell
    title="Text-to-speech"
    class="max-w-3xl"
    {actionButtons}
>
    <Tts
        {event}
        bind:forceSend
        on:done={closeModal}
    />
</ModalShell>