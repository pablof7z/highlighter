<script lang="ts">
	import { ComponentType, onDestroy, setContext } from 'svelte';
	import { Readable, Writable, writable } from 'svelte/store';
	import { layout } from "$stores/layout";
    import Header from "./Header.svelte";
    import * as Studio from '$components/Studio';
    import Publish from './Publish.svelte';

    export let state: Writable<Studio.State<Studio.Type>>;
    export let actions: Studio.Actions;
    export let authorUrl: string;

    $layout.header = {
        component: Header,
        props: {
            state,
            actions,
            // onSaveDraft: async (manuallySaved: boolean) => {
            //     if ($event) {
            //         const res = addDraftCheckpoint(
            //             manuallySaved,
            //             draft,
            //             { event: JSON.stringify($event!.rawEvent()) },
            //             "article",
            //             $event!
            //         )

            //         if (res) {
            //             draft = res;
            //             return true;
            //         }
            //     }
            // },
            // onPublish: async () => {
            //     $state.mode = 'publish';
            // }
        }
    }

    onDestroy(() => {
        $layout.header = undefined;
    });

    let editorComponent: ComponentType;
    let previewComponent: ComponentType;

    $: {
        const componentName = $state.type.charAt(0).toUpperCase() + $state.type.slice(1) as keyof typeof Studio.Editor;
        editorComponent = Studio.Editor[componentName] as ComponentType;
        previewComponent = Studio.Preview[componentName] as ComponentType;
    }

    $: {
        const componentName = $state.type.charAt(0).toUpperCase() + $state.type.slice(1) as keyof typeof Studio.Editor;
    }
</script>

<div class="flex flex-col w-full">
    <div class:hidden={$state.mode !== 'audience'}>
        <!-- <Audience
            {preview}
            {type}
            {withPreview}
            {publishInGroups}
            {publishInTiers}
            {publishScope}
        /> -->
    </div>
    <div class:hidden={$state.mode !== 'edit'}>
        {#if editorComponent}
            <svelte:component this={editorComponent} {state} />
        {:else}
            <div>Editor for {$state.type} not ready yet</div>
        {/if}
        <!-- <slot {mode} {event} /> -->
    </div>
    {#if $state.mode === 'preview'}
        {#if previewComponent}
            <svelte:component this={previewComponent} {state} />
        {:else}
            <div>Preview for {$state.type} not ready yet</div>
        {/if}
    {:else if $state.mode === 'publish'}
        <Publish
            {state}
            {authorUrl}
        />
    {/if}
</div>