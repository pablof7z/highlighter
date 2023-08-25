<script lang="ts">
    import { createEventDispatcher } from "svelte";
	import { fade, slide } from "svelte/transition";

    export let name: string;
    export let value: string[];
    export let values: string[]

    let val: string = (value ? value[0] : undefined) || "";

    const dispatch = createEventDispatcher();

    let showDropdown = false;

    function change() {
        value = [val];
        dispatch("change", { name, value });
    }
</script>

<div class="flex flex-row gap-2">
    <p>{name}</p>
    <div class="dropdownd">
        <input
            tabindex="0"
            class="input input-bordered input-sm"
            bind:value={val}
            on:focus={() => showDropdown = true}
            on:blur={() => setTimeout(() => {showDropdown = false}, 200)}
            on:change={change}
            on:keyup={change}
        />
        {#if values && values.length > 0 && showDropdown}
            <ul class="dropdown-content menu z-[1] p-2 shadow bg-base-100 rounded-box line-clamp-1" transition:slide={{duration:400, axis: 'y'}}>
                {#each values as v}
                    <li>
                        <button on:click={() => {val = v; change()}}>{v}</button>
                    </li>
                {/each}
            </ul>
        {/if}
    </div>
</div>