<script lang="ts">
	import ModalShell from "$components/ModalShell.svelte";
    import { NDKEvent } from "@nostr-dev-kit/ndk";

    export let event: NDKEvent;
</script>

<ModalShell
    title="Zap"
>
    <Zap
        {event}
        buttonClass="button"
    />
</ModalShell>