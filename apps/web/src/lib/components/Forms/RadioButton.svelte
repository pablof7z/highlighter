<script lang="ts">
	import { Check, CheckFat } from "phosphor-svelte";
    import { createEventDispatcher } from "svelte";

    export let currentValue: string | undefined = undefined;
    export let value: string | undefined = undefined;
    export let color = "accent";

    const dispatch = createEventDispatcher();

    let selected: boolean;

    $: selected = currentValue === value;

    function onClick() {
        currentValue = value;
        dispatch("click", value);
    }
</script>

<button class="
    text-left
    border-2 rounded p-2 px-4
    flex flex-row gap-2 items-center justify-between w-full {$$props.class??""}
    hover:bg-{color}/10 hover:text-{color}-foreground
    { selected ? `border-${color}` : "border-muted-foreground opacity-50 hover:opacity-100"}
" on:click={onClick}>
    <div class="flex flex-row items-start w-full">
        <div class="flex flex-row gap-10 justify-stretch items-center w-full">
            <div class="flex flex-col items-start grow w-full">
                <span><slot /></span>
                <div>
                    <slot name="description" />
                </div>
            </div>

            {#if !$$props.skipCheck}
                <CheckFat size={20} weight="fill" class="text-{color} { selected ? "" : "opacity-0" }" />
                <!-- <Checkbox checked={true}/> -->
            {/if}
        </div>
    </div>
</button>
