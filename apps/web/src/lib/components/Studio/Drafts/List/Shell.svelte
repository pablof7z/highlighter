<script lang="ts">
	import { drafts } from "$stores/drafts";
    import Item from "./Item.svelte";
</script>

<ul class="w-full flex flex-col gap-6">
    {#each $drafts as draft (draft.id)}
        <Item item={draft} />
    {/each}
</ul>
