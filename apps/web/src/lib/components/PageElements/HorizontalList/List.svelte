<script lang="ts">
	import { CaretRight } from "phosphor-svelte";
	import { inview } from "svelte-inview";

    export let title: string | undefined = undefined;
    export let href: string | undefined = undefined;
    export let renderLimit = 3;
    export let renderLimitIncrement = renderLimit;

    export let items: any[] = [];
</script>

<div class="w-full flex flex-row max-sm:w-screen py-[var(--section-vertical-padding)] {$$props.class??""}">
    <div class="w-full flex flex-col">
        {#if title}
            <a {href} class="section-title">
                {title}
                <CaretRight class="text-muted-foreground" size={18} />
            </a>
        {/if}
        <div class="flex flex-row flex-nowrap overflow-x-auto scrollbar-hide">
        <!-- <ScrollArea class="whitespace-nowrap scrollbar-hide max-sm:w-screen" orientation="horizontal"> -->
            <div class="flex w-max gap-8">
                {#each items.slice(0, renderLimit) as item, i (item.id)}
                    <slot {item} />
                {/each}

                {#if renderLimit < items.length}
                    <button class="opacity-0 h-0" on:click={() => { renderLimit++; }} use:inview on:inview_change={(e) => {
                        if (e.detail.inView) {
                            renderLimit += renderLimitIncrement;
                        }
                    }}>
                        load more
                    </button>
                {/if}
            </div>
        </div>
        <!-- </ScrollArea> -->
    </div>
</div>
