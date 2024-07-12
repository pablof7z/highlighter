<script lang="ts">
	import { Button } from "$components/ui/button";
	import { NDKEvent, NDKUser } from "@nostr-dev-kit/ndk";
	import { Check, Lightning } from "phosphor-svelte";

    export let target: NDKEvent | NDKUser;
    export let zapped = false;
    export let open: (view: string) => void;

    let _zapped = zapped;

    // after zapping, the button will be green for 2 seconds
    $: if (_zapped) {
        _zapped = false;
        setTimeout(() => zapped = false, 2000);
    }
</script>

<Button
    variant={zapped ? undefined : "accent"}
    class="
        flex-none w-12 h-12 p-2
        rounded
        {zapped ? 'bg-green-500' : ''}
    "
    on:click={() => {
        open('zap')
    }}
>
    {#if !zapped}
        <Lightning class="w-full h-full" weight="fill" />
    {:else}
        <Check class="w-full h-full" weight="bold" />
    {/if}
</Button>