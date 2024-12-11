<script lang="ts">
	import type { EditorState } from "../state.svelte";
	import { Button } from "@/components/ui/button";
	import { Input } from "@/components/ui/input";
	import CoverImage from "../Editor/buttons/CoverImage.svelte";

    type Props = {
		editorState: EditorState;
        onClose?: () => void;
	}

	const { editorState = $bindable(), onClose }: Props = $props();

    let tags = $derived(editorState.tags.join(','));
    let tagsInput = $state(tags);
</script>

<div class="flex flex-col h-full">
    <div class="flex flex-col gap-2 grow">
        <h2 class="text-base text-muted-foreground font-medium">
            Cover Image
        </h2>

        <CoverImage {editorState}
            class="!w-fit h-32 bg-transparent min-w-32 bg-muted"
            imgProps={{ class: '!w-auto h-full object-contain'}}
        />

        <div class="flex flex-col gap-1">
            <h2 class="text-base text-muted-foreground font-medium">
                Tags
            </h2>
            <h3 class="text-xs text-muted-foreground/70">
                Add tags to help others find your content. These tags won't appear in the body of your content.
            </h3>
        </div>

        <Input
            placeholder="Add tags, separated by commas (e.g. 'art, photography')"
            class="w-full"
            bind:value={tagsInput}
            oninput={() => {
                editorState.tags = tagsInput.split(',')
                    .map(tag => tag.trim())
                    .filter(tag => tag.length > 0);
            }}
        />

    </div>

    {#if onClose}
        <div class="flex flex-row justify-end justify-self-end">
            <Button variant="default" class="px-10" onclick={onClose}>Close</Button>
        </div>
    {/if}
</div>