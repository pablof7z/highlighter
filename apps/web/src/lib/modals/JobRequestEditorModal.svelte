<script lang="ts">
    import { ModalWrapper } from "@kind0/ui-common";
	import JobRequestEditor from '$components/jobs/JobRequestEditor/JobRequestEditor.svelte';
	import type { NDKDVMRequest, NDKEvent } from '@nostr-dev-kit/ndk';
	import { closeModal } from 'svelte-modals';

    export let jobRequest: NDKDVMRequest | undefined = undefined;
    export let suggestedJobRequestInput: NDKDVMRequest | undefined = undefined;
    export let jobs: NDKEvent[] | undefined = undefined;
</script>

<ModalWrapper class="max-w-5xl w-full" bodyClass="p-0" title="New Job Request">
    <JobRequestEditor
        bind:jobRequest
        {suggestedJobRequestInput}
        {jobs}
        on:created={closeModal}
        on:cancel={closeModal}
    />
</ModalWrapper>
