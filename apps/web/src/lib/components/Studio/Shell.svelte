<script lang="ts">
	import { ComponentType, onDestroy, setContext } from 'svelte';
	import { Readable, Writable, writable } from 'svelte/store';
	import { layout } from "$stores/layout";
    import Header from "./Header.svelte";
    import * as Studio from '$components/Studio';
    import Publish from './Publish.svelte';
	import { Star } from 'phosphor-svelte';
	import { Button } from '$components/ui/button';
	import ManagePreview from './ManagePreview.svelte';

    export let state: Writable<Studio.State<Studio.Type>>;
    export let actions: Studio.Actions;
    export let authorUrl: string;

    $layout.fullWidth = true;
    $layout.header = {
        component: Header,
        props: {
            state,
            actions,
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

<div class="flex flex-col w-full lg:max-w-[var(--content-focused-width)] mx-auto lg:w-full lg:px-0">
    <div class:hidden={$state.mode !== 'manage-preview'}>
        <ManagePreview {state} />
    </div>

    <div class:hidden={$state.mode !== 'edit'}>
        {#if $state.audience.scope === 'private'}
            <div class="border px-4 py-2 bg-secondary flex flex-row justify-between gap-4 my-2 rounded">
                <div class="flex flex-row" class:items-center={!$state.withPreview}>
                    <Star class="w-4 h-4 mr-2 text-gold" weight="fill" />
                    <div class="text-sm text-muted-foreground flex flex-col items-start">
                        For community members only.
                        {#if $state.withPreview}
                            <span class="text-xs opacity-50">Non-members will see a preview.</span>
                        {/if}
                    </div>
                </div>

                <div class="flex flex-row items-center">
                    <Button variant="outline" size="sm" on:click={() => $state.mode = 'manage-preview'}>
                        Manage preview
                    </Button>
                </div>
            </div>
        {/if}
        
        
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