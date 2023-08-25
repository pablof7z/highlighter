<script lang="ts">
	import { ModalWrapper } from "@kind0/ui-common";
	import { closeModal } from "svelte-modals";
    import Nip89Tool from "$components/dvms/Nip89Tool/Nip89Tool.svelte";
	import type { NDKAppHandlerEvent } from "@nostr-dev-kit/ndk";

    export let nip89event: NDKAppHandlerEvent | undefined = undefined;
</script>

<ModalWrapper title="NIP-89 Tool" bodyClass="flex flex-col gap-6">
    <Nip89Tool
        {nip89event}
        on:cancel={closeModal} on:done={closeModal}
    />
</ModalWrapper>