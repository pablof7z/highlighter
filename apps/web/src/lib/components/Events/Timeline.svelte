<script lang="ts">
	import { getContent } from "$stores/user-view";
	import { EventCard, ndk } from "@kind0/ui-common";
	import type { NDKUser } from "@nostr-dev-kit/ndk";

    export let user: NDKUser;

    const content = getContent();
</script>

<div class="flex flex-col gap-4">
    {#each $content as event (event.id)}
        <EventCard {event}>
            {event.content}
        </EventCard>
    {/each}
</div>