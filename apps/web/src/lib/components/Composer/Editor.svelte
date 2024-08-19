<script lang="ts">
	import { Writable } from "svelte/store";
	import { State } from ".";
	import Avatar from "$components/User/Avatar.svelte";
	import currentUser from "$stores/currentUser";
    import * as Editor from "$components/Editor";

    export let state: Writable<State>;
    export let placeholder: string | undefined = undefined;
    export let minHeight = "10rem";
</script>

{#if state}
    <div class="flex flex-row gap-4">
        <Avatar user={$currentUser} size="small" />
        
        <Editor.Root
            bind:content={$state.content}
            {placeholder}
        >
            <Editor.Shell />
        </Editor.Root>
    </div>
{/if}