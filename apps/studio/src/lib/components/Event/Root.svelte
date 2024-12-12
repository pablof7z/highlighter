<script lang="ts">
	import type { NDKEvent } from "@nostr-dev-kit/ndk";
	import { ndk } from "@/state/ndk";
	import { wrapEvent } from "@highlighter/common";

    type Props = {
        eventId: string;
        loading?: boolean;
        children?: any;
        event?: NDKEvent | null;
    };

    let { eventId, loading = $bindable(false), children, event = $bindable() }: Props = $props();

    const sanitizedEventId = $derived(eventId.replace(/^nostr:/, ''));

    let prevEventId = $state<string | null>(null);

    $effect(() => {
        if (sanitizedEventId && prevEventId !== sanitizedEventId) {
            loading = true;
            event = null;
            ndk.fetchEvent(sanitizedEventId).then((e) => {
                if (e) event = wrapEvent(e, true);
            })
            .finally(() => {
                loading = false;
            });
        }
    });

    $inspect('event fetcher', event);
</script>

{#if event}
    {@render children()}
{:else}
    Loading event {sanitizedEventId}...
{/if}
