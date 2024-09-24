<script lang="ts">
    import Option from "./Pricing/Option.svelte";
    import type { Writable } from 'svelte/store';
    import type { CreateState } from "./index.js";
	import { presets } from "./Pricing";

    export let state: Writable<CreateState>;
    let selection: string = "0";

    $: if (state) {
        $state.amounts = presets[parseInt(selection)];
    }
</script>

{#each presets as amounts, i}
    <Option {amounts} bind:selection {i} />
{/each}
