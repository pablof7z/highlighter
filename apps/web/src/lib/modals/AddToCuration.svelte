<script lang="ts">
	import AddToCuration from "$components/Event/Curation/AddToCuration.svelte";
    import ModalShell from "$components/ModalShell.svelte";
	import { appMobileView } from "$stores/app";
	import { closeModal } from "$utils/modal";
	import { NDKEvent } from "@nostr-dev-kit/ndk";
	import { Block, Button, Link, Page, Toolbar } from "konsta/svelte";

    export let event: NDKEvent;
</script>

<ModalShell
    class="max-w-prose"
    title="Add to Curation"
>
    {#if $appMobileView}
        <Toolbar top title="Add to Curation">
            <Link class="right" onClick={closeModal}>
                Close
            </Link>
        </Toolbar>
    {/if}
    
    <AddToCuration {event} />
</ModalShell>