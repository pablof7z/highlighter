<script lang="ts">
	import * as Editor from '@components/Editor';
	import Avatar from '@components/user/Avatar.svelte';
	import { currentUser } from '@/state/current-user.svelte';
	import Button from '@/components/ui/button/button.svelte';
	import { Plus } from 'lucide-svelte';
	import { crossfade, fly, slide } from 'svelte/transition';
	import { cubicInOut } from 'svelte/easing';
	import { Editor as EditorType } from 'svelte-tiptap';
	import type { PostState } from '../state/index.svelte';
    const user = $derived.by(currentUser);

    type Props = {
        postState: PostState;
    }

	let { postState = $bindable() }: Props = $props();

	let showMentions = $state(false);

    if (postState.contents.length === 0) {
        postState.contents = [''];
    }

    const [send, receive] = crossfade({
		duration: 250,
		easing: cubicInOut,
	});

	function addThreadItem() {
		postState.contents = [...postState.contents, ''];
	}

    const lastContent = $derived(postState.contents[postState.contents.length - 1]);
    const showAddButton = $derived(lastContent.length > 0);

    let focusIndex = $state(postState.contents.length - 1);
    let editors = $state<EditorType[]>([]);
</script>

<div class="mx-auto flex h-full w-full max-w-3xl flex-col items-stretch justify-stretch p-4">
	<div class="text-muted-foreground min-h-[70vh] w-full">
        {#each postState.contents as content, i}
            <div class="flex gap-4" transition:fly={{ y: -100, duration: 250, easing: cubicInOut }}>
				<div class="flex flex-col items-center">
					<Avatar of={user} size="medium" />
                    {#if i < postState.contents.length - 1 || showAddButton}
                        <div transition:fly={{ y: -100, duration: 250, easing: cubicInOut }} class="w-0.5 grow bg-border transition-all duration-300" />
                    {/if}
				</div>
                <div class="grow py-1 min-h-24">
					<Editor.Root
						bind:content={postState.contents[i]}
						bind:showMentions
                        markdown={false}
						skipToolbar={true}
                        bind:editor={editors[i]}
                        onFocus={() => focusIndex = i}
                        onKeyDown={(editor, event) => {
                            if (event.key === 'Enter' && event.shiftKey) {
                                event.preventDefault();
                                addThreadItem();
                            }

                            const index = focusIndex;
                            const content = postState.contents[index];
                            if (event.key === 'Backspace' && content.length === 0) {
                                postState.contents.splice(index, 1);
                                editors.splice(index, 1);
                            }

                            // if pressing down at the end of the editor, move focus
                            if (event.shiftKey) {
                                if (event.key === 'ArrowDown' && i === focusIndex) {
                                    editors[i + 1]?.commands.focus();
                                } else if (event.key === 'ArrowUp' && i === focusIndex) {
                                    editors[i - 1]?.commands.focus();
                                }
                            }
                        }}
					/>
				</div>
            </div>
        {/each}

        {#if showAddButton}
            <div class="mb-4 flex gap-4" transition:fly={{ y: -100, duration: 250, easing: cubicInOut }}>
                <div class="flex flex-col items-center">
                    <Button variant="outline" size="icon" class="w-8 h-8 rounded-full" onclick={addThreadItem}>
                        <Plus class="h-4 w-4" />
                    </Button>
                </div>
            </div>
        {/if}
	</div>
</div>
