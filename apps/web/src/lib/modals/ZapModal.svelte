<script lang="ts">
	import ModalShell from "$components/ModalShell.svelte";
    import { NDKEvent } from "@nostr-dev-kit/ndk";
    import { Zap } from "@kind0/ui-common";

    export let event: NDKEvent;
</script>

<ModalShell
    color="glassy"
>
    <Zap
        {event}
        buttonClass="button"
    />
</ModalShell>