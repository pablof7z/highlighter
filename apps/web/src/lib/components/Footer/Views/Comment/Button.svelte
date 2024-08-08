<script lang="ts">
	import { OpenFn } from '$components/Footer';
	import { Input } from '$components/ui/input';
	import { get, Writable } from 'svelte/store';
	import { State } from '.';

    export let open: OpenFn;
    export let placeholder = "Reply...";
    export let stateStore: Writable<State> | undefined;

    function onEditorFocused() {
        open('comment');
    }

    let content: string | undefined;
    $: content = ($stateStore?.state) && get($stateStore?.state).content;
</script>

<Input
    {placeholder}
    class="text-lg bg-background/50 rounded px-4 w-full text-muted-foreground"
    on:focus={onEditorFocused}
    value={content??""}
/>