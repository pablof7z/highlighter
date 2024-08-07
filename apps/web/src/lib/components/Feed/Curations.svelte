<script lang="ts">
	import { NDKList } from "@nostr-dev-kit/ndk";
    import { Readable } from "svelte/store";
    import * as Item from './Item';

    export let store: Readable<NDKList[]>;
</script>

<div class="flex flex-col divide-y divide-border">
    {#each $store as list, index (list.id)}
        <div class="py-[var(--section-vertical-padding)] w-full">
            <Item.Curation
                {index}
                {list}
                class="responsive-padding"
            />
        </div>
    {/each}
</div>