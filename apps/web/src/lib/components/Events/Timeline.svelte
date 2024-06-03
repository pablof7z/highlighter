<script lang="ts">
	import { getContent } from "$stores/user-view";

    const content = getContent();
</script>

<div class="flex flex-col gap-4">
    {#each $content as event (event.id)}
        <EventCard {event}>
            {event.content}
        </EventCard>
    {/each}
</div>