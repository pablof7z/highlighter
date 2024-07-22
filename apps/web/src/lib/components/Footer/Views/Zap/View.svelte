<script lang="ts">
	import { NDKEvent } from '@nostr-dev-kit/ndk';
	import Zap from "$components/Events/Zaps/Zap.svelte";

    export let event: NDKEvent;
    export let onZapped = () => {};
    export let open: (view?: string | false) => void;

    function zapped() {
        onZapped();
    }

    function zapping() {
        open(false);
    }
</script>

<Zap
    {event}
    on:zap={zapped}
    on:zapping={zapping}
/>