<script lang="ts">
    import { Checkbox } from "$lib/components/ui/checkbox";
    import { Switch } from "$lib/components/ui/switch";
	import { createEventDispatcher } from "svelte";

    const dispatch = createEventDispatcher();
    
    export let value: boolean | undefined = undefined;
    export let type: "check" | "switch" = "check";
    export let icon: string | undefined = undefined;

    function toggle() {
        value = !value;
        dispatch("change", { value });
    }
</script>

<button class="
    text-left
    border-2 rounded p-2 px-4
    bg-secondary/30
    flex flex-row gap-2 items-center justify-between w-full {$$props.class??""}
">

    <div class="flex flex-row-reverse md:flex-row items-start md:items-center  w-full space-x-2">
        {#if type === 'check'}
            <Checkbox bind:checked={value} on:click={toggle} />
        {/if}

        {#if icon}
            <img src={icon} class="w-10 h-10 rounded-sm" />
        {:else if $$slots.icon}
            <slot name="icon" />
        {/if}

        <button class="text-left flex flex-row-reverse md:flex-row gap-2 justify-stretch items-center w-full" on:click={toggle}>
            <div class="flex flex-col items-start grow w-full">
                <div class="font-medium">
                    <slot />
                </div>
                <div class="text-muted-foreground text-xs">
                    <slot name="description" />
                </div>
            </div>

            {#if type === 'switch'}
                <Switch bind:checked={value} on:click={(e) => e.preventDefault() } />
            {/if}

            {#if $$slots.button}
            <div class="flex shrink items-stretch max-sm:w-full whitespace-nowrap"
                class:opacity-50={!value}
                class:pointer-events-none={!value}
            >
                <slot name="button" />
            </div>
            {/if}
        </button>
    </div>

</button>