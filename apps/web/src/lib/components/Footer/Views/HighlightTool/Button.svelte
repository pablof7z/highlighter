<script lang="ts">
	import { Check } from 'phosphor-svelte';
	import { Button } from "$components/ui/button";
	import HighlightIcon from '$icons/HighlightIcon.svelte';

    export let zapped = false;
    let _zapped = zapped;

    // after zapping, the button will be green for 2 seconds
    $: if (_zapped) {
        _zapped = false;
        setTimeout(() => zapped = false, 2000);
    }
</script>

<Button
    variant={zapped ? undefined : "transparent"}
    class="
        flex-none w-10 h-10 p-2
        {zapped ? 'bg-green-500' : ''}
    "
    on:click
>
    {#if !zapped}
        <HighlightIcon class="w-full h-full" weight="fill" />
    {:else}
        <Check class="w-full h-full" weight="bold" />
    {/if}
</Button>
