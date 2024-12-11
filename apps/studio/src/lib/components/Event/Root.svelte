<script lang="ts">
	import type { NDKEvent } from "@nostr-dev-kit/ndk";
	import AvatarWithName from "../user/AvatarWithName.svelte";
	import { ndk } from "@/state/ndk";
	import { wrapEvent } from "@highlighter/common";

    type Props = {
        eventId: string;
        loading?: boolean;
        children?: any;
        event?: NDKEvent | null;
    };

    let { eventId, loading = $bindable(false), children, event = $bindable() }: Props = $props();

    let prevEventId = $state<string | null>(null);

    $effect(() => {
        if (eventId && prevEventId !== eventId) {
            loading = true;
            event = null;
            ndk.fetchEvent(eventId).then((e) => {
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
    Loading event {eventId}...
{/if}
