<script lang="ts">
	import AddToCuration from "$components/Event/Curation/AddToCuration.svelte";
    import ModalShell from "$components/ModalShell.svelte";
	import { NDKEvent } from "@nostr-dev-kit/ndk";

    export let event: NDKEvent;
</script>

<ModalShell
    class="max-w-2xl"
>
    <AddToCuration {event} />
</ModalShell>