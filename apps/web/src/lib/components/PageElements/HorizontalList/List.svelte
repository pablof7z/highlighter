<script lang="ts">
	import { ScrollArea } from "$components/ui/scroll-area";
	import { CaretRight } from "phosphor-svelte";

    export let title: string | undefined = undefined;
    export let href: string | undefined = undefined;

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
                    {#each items as item (item.id)}
                        <div class="px-4">
                            <slot {item} />
                        </div>
                    {/each}
                </div>
            </ScrollArea>
        </div>
    </div>

<style lang="postcss">
    a {
        @apply font-bold text-xl text-foreground;
    }
</style>