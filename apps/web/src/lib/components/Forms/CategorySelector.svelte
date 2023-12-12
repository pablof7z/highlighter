<script lang="ts">
    import { categories as allCategories } from "$utils/categories";

    export let categories: string[] = [];
</script>

<div class="flex flex-col gap-2 ">
    <label class="text-white font-semibold text-lg">Categories</label>
    <select bind:value={categories} multiple class="select max-w-md">
        {#each allCategories as category}
            <option value={category}>{category}</option>
        {/each}
    </select>
</div>