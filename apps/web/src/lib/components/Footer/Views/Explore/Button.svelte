<script lang="ts">
	import { OpenFn } from '$components/Footer';
	import { Input } from '$components/ui/input';
	import { Writable } from 'svelte/store';
	import { State } from '.';
	import { MagnifyingGlass } from 'phosphor-svelte';

    export let open: OpenFn;
    export let mainView: string;
    export let placeholder = "Reply...";
    export let stateStore: Writable<State>;

    let autofocus = false;

    function onEditorFocused() {
        open('explore');
        autofocus = true;
    }
</script>

<div class="flex flex-row relative w-full transition-all duration-300">
    <MagnifyingGlass class="absolute top-1/2 left-3 transform -translate-y-1/2 text-muted-foreground" />
    <Input
        class="text-lg bg-background/50 rounded px-4 w-full text-muted-foreground pl-10"
        on:focus={onEditorFocused}
        on:keydown={$stateStore.onKeyDown}
        placeholder="Explore"
        bind:value={$stateStore.search}
    />
</div>