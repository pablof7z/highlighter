<script lang="ts">
    import { MessageCircleWarning } from "lucide-svelte";
    import { EditorState } from "../../state.svelte";
	import { Button } from "@/components/ui/button";
    import SettingsModal from "../../Settings/Modal.svelte";
	import CoverImage from "../buttons/CoverImage.svelte";

    type Props = {
        editorState: EditorState;
        allGood: boolean;
    }

    let { editorState, allGood = $bindable() }: Props = $props();

    const hasRelays = $derived(editorState.relays.length > 0)
    const hasImage = $derived(!!editorState.image)
    const hasContent = $derived(!!editorState.content)

    let settingsOpen = $state(false);
    let activePage = $state("");

    $effect(() => {
        allGood = (
            hasRelays && hasContent
        )
    })

    function open(page: string) {
        activePage = page;
        settingsOpen = true;
    }
</script>

{#if !hasRelays}
    <div class="text-sm text-red-500 flex flex-row gap-6 items-center rounded-lg p-4">
        <div class="flex flex-row  items-center gap-2 grow">
            <MessageCircleWarning class="h-4 w-4" />
            You must have at least one relay to publish.
        </div>

        <div class="self-end">
            <Button variant="secondary" size="sm" class="px-6" onclick={() => { open("Relays") }}> 
                Fix
            </Button>
        </div>
    </div>
{/if}

{#if !hasImage}
    <div class="text-sm text-orange-500 flex flex-row gap-6 items-center rounded-lg p-4">
        <div class="flex flex-row  items-center gap-2 grow">
            <MessageCircleWarning class="h-4 w-4" />
            Consider adding an image to your post.
        </div>

        <div class="self-end">
            <CoverImage
                {editorState}
                variant="secondary"
                class="px-6"
            > 
                Fix
            </CoverImage>
        </div>
    </div>
{/if}



<SettingsModal {editorState} bind:open={settingsOpen} bind:selectedSetting={activePage} />