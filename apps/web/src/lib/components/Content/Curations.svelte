<script lang="ts">
    import { NDKList } from "@nostr-dev-kit/ndk";
	import { getContext } from "svelte";
	import { Readable } from "svelte/store";
    import * as Card from "$components/Card";

    const curations = getContext("curations") as Readable<NDKList[]>;
</script>

<div class="flex flex-col gap-4">
    heres
    {#each $curations as event (event.id)}
    item
        <Card.FeaturedList list={event} />
    {/each}
</div>
