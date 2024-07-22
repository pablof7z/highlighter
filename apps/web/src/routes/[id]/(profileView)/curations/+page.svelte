<script lang="ts">
    import { NDKList } from "@nostr-dev-kit/ndk";
	import { getContext } from "svelte";
	import { Readable } from "svelte/store";
    import * as Card from "$components/Card";

    const curations = getContext("userCurations") as Readable<NDKList[]>;
</script>

<div class="flex flex-col gap-4">
    {#each $curations as event (event.id)}
        <Card.FeaturedList list={event} />
    {/each}
</div>
