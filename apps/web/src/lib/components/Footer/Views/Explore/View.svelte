<script lang="ts">
	import { Writable } from "svelte/store";
	import { State } from ".";
	import Search from "$views/Search.svelte";

    export let stateStore: Writable<State>;
</script>

<div class="h-[90dvh]">
    {$stateStore.search}
    <Search
        skipInput
        placeholder="Explore"
        bind:value={$stateStore.search}
        bind:keydown={$stateStore.onKeyDown}
        containerClass="px-2"
        inputClass="grow h-11 bg-transparent rounded-full !pr-4 p-2 !text-lg
            rounded-b-none shadow-none !outline-0
            placeholder:text-muted-foreground
        "
    />
</div>