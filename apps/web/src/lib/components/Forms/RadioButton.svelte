<script lang="ts">
	import { Button } from "$components/ui/button";
	import { Check } from "phosphor-svelte";
    import { createEventDispatcher } from "svelte";

    export let currentValue: string | undefined = undefined;
    export let value: string | undefined = undefined;

    const dispatch = createEventDispatcher();

    let selected: boolean;

    $: selected = currentValue === value;

    function onClick() {
        currentValue = value;
        dispatch("click", value);
    }
</script>

<Button variant="outline" class="
    flex flex-row gap-2 items-center justify-between w-full {$$props.class??""}
    hover:bg-accent/10 hover:text-accent-foreground
    { selected ? "border-accent" : ""}
" on:click={onClick}>
    <div class="flex flex-row items-start w-full">
        <div class="flex flex-row gap-2 justify-stretch items-start w-full">
            <div class="flex flex-col items-start grow w-full">
                <span><slot /></span>
                <div>
                    <slot name="description" />
                </div>
            </div>

            {#if !$$props.skipCheck}
                <Check class="text-accent {!selected ? 'hidden' : ''}" />
            {/if}
        </div>
    </div>
</Button>
