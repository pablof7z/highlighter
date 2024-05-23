<script lang="ts">
	import { SvelteComponent } from "svelte";
	import { scale } from "svelte/transition";

    export let icon: typeof SvelteComponent;
    export let active: boolean;

    /**
     * A class, like hover:bg-red-400/20, to apply to the button.
     */
    export let buttonClass: string;

    export let bgClass: string;

    /**
     * A class conditional on active state, like
     * {active ? "text-red-500" : "text-red-400/30 group-hover:text-red-500"}
     */
    export let iconClass: string;
</script>

<button class="
    !rounded-full p-2 group
    relative overflow-clip
    flex items-center justify-center
    flex-none min-w-[3rem]
    {buttonClass}
" on:click>
    <div class="
        absolute -z-10 transition-all duration-300 rounded-full
        {bgClass}
        { active ? "w-full h-full bg-opacity-20" : "!w-0 !h-0" }
    "></div>
    {#key active}
        <span in:scale>
            <svelte:component this={icon} class="
                w-6 h-6 z-1
                {iconClass}
            " weight={active ? "fill" : "regular"}
            />
        </span>
    {/key}
</button>
