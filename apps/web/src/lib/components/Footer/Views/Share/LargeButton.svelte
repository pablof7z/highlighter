<script lang="ts">
	import { OpenFn } from "$components/Footer";
	import { Button } from "$components/ui/button";
	import ShareModal from "$modals/ShareModal.svelte";
	import { openModal } from "$utils/modal";
	import { NDKArticle, NDKEvent } from "@nostr-dev-kit/ndk";
	import { Repeat } from "phosphor-svelte";

    export let open: OpenFn;
    export let event: NDKEvent;
</script>

<Button
    variant="secondary"
    class="footer-button flex flex-col items-center gap-2 h-auto p-2"
    on:click={() => openModal(ShareModal, { event })}
>
    <Repeat size={40} />
    Share
</Button>
