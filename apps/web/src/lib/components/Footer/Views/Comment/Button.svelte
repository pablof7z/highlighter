<script lang="ts">
	import { OpenFn } from '$components/Footer';
	import { get, Writable } from 'svelte/store';
	import { State } from '.';
	import CommentsButton from '$components/buttons/CommentsButton.svelte';
	import { NDKEvent } from '@nostr-dev-kit/ndk';
	import { openModal } from '$utils/modal';
	import NewPostModal from '$modals/NewPostModal.svelte';

    export let open: OpenFn;
    export let placeholder = "Reply...";
    export let stateStore: Writable<State> | undefined;
    export let event: NDKEvent;

    function reply() {
        openModal(NewPostModal, { replyTo: event });
    }

    let content: string | undefined;
    $: content = ($stateStore?.state) && get($stateStore?.state).content;
</script>

<CommentsButton {event} on:click={reply} />
