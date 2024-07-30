<script lang="ts">
	import { Button } from "$components/ui/button";
    import * as Tooltip from "$lib/components/ui/tooltip";
	import { Check, PencilRuler } from "phosphor-svelte";
    
    export let save: () => Promise<boolean>;

    let manuallySaved = false;
    let state: "idle" | "saving" | "saved" = "idle";

    async function click() {
        manuallySaved = true;
        state = "saving";

        if (await save()) {
            state = "saved";
            setTimeout(() => { state = "idle"; }, 2000);
        } else {
            console.error("Failed to save");
        }
    }
</script>

<Tooltip.Root>
    <Tooltip.Trigger>
        <Button size="icon" variant="outline" class="{state === 'saved' && manuallySaved ? "bg-green-500/50" : ""} transition-all duration-500" on:click={click}>
            {#if state === "idle"}
                <PencilRuler size={24} />
            {:else}
                <span class:animate-pulse={state === "saving"}>
                    <Check size={24} />
                </span>
            {/if}
        </Button>
    </Tooltip.Trigger>
    <Tooltip.Content>
        Save Draft
    </Tooltip.Content>
</Tooltip.Root>