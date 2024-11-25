<script lang="ts">
	import { Check, CheckFat } from "phosphor-svelte";
    import { createEventDispatcher } from "svelte";
	import Checkbox from "./Checkbox.svelte";

    export let color = "accent";
    export let checked: boolean;

    const dispatch = createEventDispatcher();

    function onClick() {
        checked = !!checked;
        dispatch("click", checked);
        dispatch("changed", checked);
    }
</script>

<button class="
    text-left
    border-2 rounded p-2 px-4
    bg-secondary/30
    flex flex-row gap-2 items-center justify-between w-full {$$props.class??""}
    hover:bg-{color}/10 hover:text-{color}-foreground
    { checked ? "border-gold" : ""}
" on:click={onClick}>
    <div class="flex flex-row items-start w-full">
        <Checkbox bind:value={checked} />
        
        <div class="flex flex-row gap-10 justify-stretch items-center w-full">
            <div class="flex flex-col items-start grow w-full gap-1">
                <span class="font-medium text-base { checked ? "text-gold" : ""}"><slot /></span>
                {#if $$slots.description}
                    <div class="text-muted-foreground text-sm">
                        <slot name="description" />
                    </div>
                {/if}
            </div>

            {#if $$slots.icon}
                <slot name="icon" />
            {/if}
        </div>
    </div>
</button>
