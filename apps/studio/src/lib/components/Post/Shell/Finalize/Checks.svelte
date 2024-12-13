<script lang="ts">
    import { MessageCircleWarning } from "lucide-svelte";
    import { type PostState, type ValidationError } from "@components/Post/state/index.svelte";
	import { Button } from "@/components/ui/button";
    import SettingsModal from "../Settings/Modal.svelte";
	import CoverImage from "../buttons/CoverImage.svelte";

    type Props = {
        postState: PostState;
        allGood: boolean;
    }

    let { postState, allGood = $bindable() }: Props = $props();

    const errors = $derived.by(postState.validate.bind(postState));

    let settingsOpen = $state(false);
    let activePage = $state("");

    const criticalErrors: ValidationError[] = [
        'missing-relays',
        'missing-title',
        'missing-content',
        'missing-notes',
    ];

    $effect(() => {
        allGood = !errors.some(error => criticalErrors.includes(error))
    })

    function open(page: string) {
        activePage = page;
        settingsOpen = true;
    }
</script>

{#each errors as error}
    {#if error === 'missing-relays'}
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
    {:else if error === 'missing-title'}
        <div class="text-sm text-red-500 flex flex-row gap-6 items-center rounded-lg p-4">
            <div class="flex flex-row  items-center gap-2 grow">
                <MessageCircleWarning class="h-4 w-4" />
                You must have a title.
            </div>
        </div>
    {:else if error === 'missing-summary'}
        <div class="text-sm text-orange-500 flex flex-row gap-6 items-center rounded-lg p-4">
            <div class="flex flex-row  items-center gap-2 grow">
                <MessageCircleWarning class="h-4 w-4" />
                Consider adding a subtitle to make your post more engaging.
            </div>
        </div>
    {:else if error === 'missing-content'}
        <div class="text-sm text-red-500 flex flex-row gap-6 items-center rounded-lg p-4">
            <div class="flex flex-row  items-center gap-2 grow">
                <MessageCircleWarning class="h-4 w-4" />
                You must have content.
            </div>
        </div>
    {:else if error === 'missing-notes'}
        <div class="text-sm text-red-500 flex flex-row gap-6 items-center rounded-lg p-4">
            <div class="flex flex-row  items-center gap-2 grow">
                <MessageCircleWarning class="h-4 w-4" />
                You must have notes.
            </div>
        </div>
    {:else if error === 'missing-image'}
        <div class="text-sm text-orange-500 flex flex-row gap-6 items-center rounded-lg p-4">
            <div class="flex flex-row  items-center gap-2 grow">
                <MessageCircleWarning class="h-4 w-4" />
                Consider adding an image to your post.
            </div>

            <div class="self-end">
                <CoverImage
                    {postState}
                    variant="secondary"
                    class="px-6"
                > 
                    Fix
                </CoverImage>
            </div>
        </div>
    {:else}
        <div class="text-sm text-red-500 flex flex-row gap-6 items-center rounded-lg p-4">
            <div class="flex flex-row  items-center gap-2 grow">
                <MessageCircleWarning class="h-4 w-4" />
                {error}
            </div>
        </div>
    {/if}
{/each}

<SettingsModal {postState} bind:open={settingsOpen} bind:selectedSetting={activePage} />