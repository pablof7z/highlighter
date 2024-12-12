<script lang="ts">
	import * as Dialog from '@/components/ui/dialog';
	import type { EditorState } from '../../state.svelte';
	import { Button } from '@/components/ui/button';
	import Editor from '@components/Editor/Root.svelte';
	import SettingsModal from '../../Settings/Modal.svelte';
	import { publish } from '../../state.svelte';
	import { ArrowRightIcon, Loader2, MessageCircleWarning, Plane } from 'lucide-svelte';
	import Name from '@/components/user/Name.svelte';
	import CoverImage from '../buttons/CoverImage.svelte';
	import { fade, slide } from 'svelte/transition';
	import { NDKDraft, NDKEvent, NDKKind } from '@nostr-dev-kit/ndk';
	import { ndk } from '@/state/ndk';
	import { wrapEvent } from '@highlighter/common';

	interface Props {
		editorState: EditorState;
		open: boolean;
	}

    let { editorState = $bindable(), open = $bindable() }: Props = $props();

    let drafts = $state<NDKDraft[] | null>(null);

    $effect(() => {
        console.log('running, open', open, !!editorState.draft);
        if (!editorState.draft || drafts) return;

        drafts = ndk.$subscribe([
            { kinds: [NDKKind.DraftCheckpoint], ...editorState.draft!.filter() },
            { kinds: [NDKKind.Draft], ids: [editorState.draft!.id] },
        ], undefined, NDKDraft)

        console.log(drafts);
    })

    const orderedDrafts = $derived.by(() => {
        if (!drafts) return [];
        return [...drafts].sort((a, b) => b.created_at! - a.created_at!);
    });

	let showSettings = $state(false);
	let error = $state(null);

    let previewEvent = $state<NDKEvent | null>(null);
</script>

<Dialog.Root bind:open>
    <Dialog.Content class="p-0 w-full max-w-[calc(200px+65ch+5rem)] overflow-clip">
        {#if drafts}
        <div class="flex flex-row h-full max-h-[80vh] w-full">
            <div class="flex-none flex flex-col bg-secondary w-fit divide-y divide-border overflow-y-auto">
                {#each orderedDrafts as draft}
                {#await draft.getEvent() then event}
                {#if event}
                    {@const words = event.content.split(' ').length}
                    <button class="flex flex-col grow text-sm text-muted-foreground pl-10 px-4 text-right py-2 items-end" onclick={() => {
                        previewEvent = wrapEvent(event);
                    }}>
                        {new Date(draft.created_at! * 1000).toLocaleString()}
                        <div class="text-xs text-muted-foreground">{words} words</div>
                    </button>
                {/if}
                {/await}
                {/each}
            </div>

            <div class="flex flex-col bg-background p-8 w-full">
                {#if previewEvent}
                    <h1 class="text-5xl font-bold">{previewEvent.title}</h1>

                    {#key previewEvent.content}
                    <div class="article">
                        <Editor readonly content={previewEvent.content} skipToolbar />
                    </div>
                    {/key}
                {/if}
            </div>
        </div>
        {:else}
        no
        {/if}

        <Dialog.Footer>
        </Dialog.Footer>
    </Dialog.Content>
</Dialog.Root>
