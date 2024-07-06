<script lang="ts">
	import { ScrollArea } from "$components/ui/scroll-area";
	import { CaretRight } from "phosphor-svelte";
	import { inview } from "svelte-inview";

    export let title: string | undefined = undefined;
    export let href: string | undefined = undefined;
    export let renderLimit = 3;
    export let renderLimitIncrement = renderLimit;

    export let items: any[] = [];
</script>

    <div class="border-y border-border">
        <div class="py-4">
            {#if title}
                <a {href} class="flex flex-row items-center gap-2 px-4 mb-1">
                    {title}
                    <CaretRight class="text-muted-foreground" size={18} />
                </a>
            {/if}
            <ScrollArea class="whitespace-nowrap scrollbar-hide" orientation="horizontal">
                <div class="flex w-max">
                    {#each items.slice(0, renderLimit) as item (item.id)}
                        <div class="px-4">
                            <slot {item} />
                        </div>
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
            </ScrollArea>
        </div>
    </div>

<style lang="postcss">
    a {
        @apply font-bold text-xl text-foreground;
    }
</style>