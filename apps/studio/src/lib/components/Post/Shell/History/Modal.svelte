<script lang="ts">
	import * as Dialog from '@/components/ui/dialog';
	import type { PostState } from '@/components/Post/state/index.svelte';
	import { Button } from '@/components/ui/button';
	import Editor from '@components/Editor/Root.svelte';
	import SettingsModal from '../Settings/Modal.svelte';
	import { ArrowRightIcon, Loader2, MessageCircleWarning, Plane } from 'lucide-svelte';
	import Name from '@/components/user/Name.svelte';
	import { fade, slide } from 'svelte/transition';
	import { NDKDraft, NDKEvent, NDKKind } from '@nostr-dev-kit/ndk';
    import { wordCount } from '@highlighter/common';
	import { ndk } from '@/state/ndk';
	import { wrapEvent } from '@highlighter/common';

	interface Props {
		postState: PostState;
		open: boolean;
	}

    let { postState = $bindable(), open = $bindable() }: Props = $props();

    let drafts = $state<NDKDraft[] | null>(null);

    $effect(() => {
        console.log('running, open', open, !!postState.draft);
        if (!postState.draft?.id || drafts) return;

        drafts = ndk.$subscribe([
            { kinds: [NDKKind.DraftCheckpoint], ...postState.draft!.filter() },
            { kinds: [NDKKind.Draft], ids: [postState.draft!.id] },
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
    let selectedIndex = $state<number | null>(null);
</script>

<Dialog.Root bind:open>
    <Dialog.Content class="p-0 w-full max-w-[calc(200px+65ch+5rem)] h-[80vh] overflow-clip">
        {#if drafts}
        <div class="flex flex-row h-full w-full">
            <div class="flex-none flex flex-col w-fit divide-y divide-border overflow-y-auto bg-muted/10">
                {#each orderedDrafts as draft, i (draft.id)}
                    {#await draft.getEvent() then event}
                    {#if event}
                        {@const words = wordCount(event.content)}
                        <button class="flex flex-col gap-2 text-sm text-muted-foreground pl-10 px-4 text-right py-2 items-end bg-muted/20 border-b border-border" onclick={() => {
                            previewEvent = wrapEvent(event);
                            selectedIndex = i;
                        }}>
                            {new Date(draft.created_at! * 1000).toLocaleString()}
                            <div class="text-xs text-muted-foreground">{words} words</div>

                            {#if selectedIndex === i}
                                <Button size="sm" variant="default" class="text-xs !py-1">
                                    Restore
                                </Button>
                            {/if}
                        </button>
                    {/if}
                    {/await}
                {/each}
            </div>

            <div class="flex flex-col bg-background w-full">
                {#if previewEvent}
                    {#key previewEvent.content}
                        <div class="article max-h-[80vh] p-8 overflow-auto">
                            <Editor readonly content={previewEvent.content} skipToolbar />
                        </div>
                    {/key}
                {/if}
            </div>
        </div>
        {:else}
        no
        {/if}
    </Dialog.Content>
</Dialog.Root>
