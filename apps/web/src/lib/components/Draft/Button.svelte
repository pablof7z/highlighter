<script lang="ts">
	import { Button } from "$components/ui/button";
    import * as Tooltip from "$lib/components/ui/tooltip";
	import { Check, PencilRuler } from "phosphor-svelte";
    
    export let save: (manuallySaved: boolean) => Promise<boolean>;
    export let timer: number | undefined = undefined;

    let manuallySaved = false;
    let state: "idle" | "saving" | "saved" = "idle";

    const autoSave = async () => {
        if (state === "idle") {
            manuallySaved = false;
            state = "saving";

            if (await save(manuallySaved)) {
                state = "saved";
            } else {
                console.error("Failed to save");
            }

            setTimeout(autoSave, timer! * 1000);
        }
    }

    if (timer) {
        setTimeout(autoSave, timer * 1000);
    }

    async function click() {
        manuallySaved = true;
        state = "saving";

        if (await save(manuallySaved)) {
            state = "saved";
            setTimeout(() => { state = "idle"; }, 2000);
        } else {
            console.error("Failed to save");
        }
    }
</script>

<Tooltip.Root>
    <Tooltip.Trigger>
        <Button size="icon" variant="outline" class="{state === 'saved' && manuallySaved ? "bg-green-500/50" : ""} transition-all duration-500 {$$props.class??""}" on:click={click}>
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