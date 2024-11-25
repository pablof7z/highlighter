<script lang="ts">
	import { Button } from "$components/ui/button";
    import * as HoverCard from "$lib/components/ui/hover-card/index.js";
    import * as DrawerPrimitive from "$lib/components/ui/drawer/index.js";
	import { Inbox, ArrowRight } from "lucide-svelte";

    export let skipText = false;
</script>

<HoverCard.Root
    closeOnEscape
    openDelay={0}
>
    <HoverCard.Trigger>
        <Button variant="accent" class="flex flex-row gap-2.5 items-center p-3" on:click>
            <Inbox size={skipText ? 24 : 20} />
            {#if !skipText}
                Add to Inbox
            {/if}
        </Button>
    </HoverCard.Trigger>

    <HoverCard.Content class="w-64 flex flex-col gap-2 items-center">
        <div class="w-fit p-3 px-4 rounded bg-secondary">
            <Inbox size={48} strokeWidth={1} />
        </div>
        <h2 class="mb-0">Inbox</h2>

        
        <p class="text-sm text-muted-foreground">
            Just like your typical follow list, but razor-focused
            on following people and publications across specific content types.
        </p>
    </HoverCard.Content>
</HoverCard.Root>