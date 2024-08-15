<script lang="ts">
	import { badgeVariants } from "$components/ui/badge";
	import Badge from "$components/ui/badge/badge.svelte";


    
    export let tags: string[];
    export let clickable = true;

    const hasTags = tags.length > 0;
</script>

{#if hasTags}
    <div class="overflow-x-auto scrollbar-hide flex-nowrap w-full {$$props.class??""}">
        <div class="
            flex flex-row gap-4 flex-nowrap
            snap snap-x snap-start snap-mandatory
            whitespace-nowrap
        ">
            {#each tags as tag, i (i)}
                {#if clickable}
                    <a
                        href="/t/{encodeURIComponent(tag)}"
                        class="{badgeVariants({variant: "secondary"})} !font-normal hover:bg-foreground hover:text-background"
                    >
                        <span>{tag}</span>
                    </a>
                {:else}
                    <Badge variant="secondary" class="!font-normal">
                        <span>{tag}</span>
                    </Badge>
                {/if}
            {/each}
        </div>
    </div>
{/if}
