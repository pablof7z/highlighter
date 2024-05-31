<script lang="ts">
    export let tags: string[];
    export let clickable = true;

    const hasTags = tags.length > 0;
</script>

{#if hasTags}
    <div class="overflow-x-auto scrollbar-hide flex-nowrap w-full {$$props.class??""}">
        <div class="
            flex flex-row gap-4 flex-nowrap
            snap snap-x snap-start snap-mandatory
        ">
            {#each tags as tag, i (i)}
                {#if clickable}
                    <a
                        href="/t/{encodeURIComponent(tag)}"
                        class="tag"
                    >
                        <span>{tag}</span>
                    </a>
                {:else}
                    <span class="tag">{tag}</span>
                {/if}
            {/each}
        </div>
    </div>
{/if}

<style lang="postcss">
    .tag {
        @apply flex-row gap-2 text-white/50 text-sm inline bg-white/10 rounded-full px-3 py-1 whitespace-nowrap snap-center;
    }
</style>