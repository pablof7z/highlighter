<script lang="ts">
	import { OpenFn } from "$components/Footer";
	import { Button } from "$components/ui/button";
	import { Plus } from "phosphor-svelte";
	import { Writable } from "svelte/store";
	import { State } from ".";

    export let open: OpenFn;
    export let stateStore: Writable<State>;
</script>

{#if $stateStore.showNew}
    <div class="flex flex-row justify-between w-full gap-2">
        <Button variant="secondary" on:click={() => open(false)}>
            Cancel
        </Button>

        <Button on:click={() => $stateStore.forceSaveNewCollection = true}>
            Save
        </Button>

    </div>
{:else}
    <div class="flex flex-row justify-between w-full gap-2">
        <Button variant="outline" on:click={() => $stateStore.showNew = true}>
            <Plus size={24} class="mr-2" />
            New Collection
        </Button>

        <Button on:click={() => $stateStore.forceSaveCollections = true }>
            Save
        </Button>
    </div>
{/if}