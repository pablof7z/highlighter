<script lang="ts">
	import createHighlightFromSelection from "$actions/highlights/create-from-selection";
	import { OpenFn } from "$components/Footer";
    import { Button } from "$components/ui/button";
	import HighlightIcon from "$icons/HighlightIcon.svelte";
	import NewPostModal from "$modals/NewPostModal.svelte";
	import QuoteModal from "$modals/QuoteModal.svelte";
	import { activeSelection } from "$stores/highlight-tool";
	import { layout } from "$stores/layout";
	import { openModal } from "$utils/modal";
	import { getTextFromSelection } from "$utils/text";
	import { NDKEvent } from "@nostr-dev-kit/ndk";
	import { Quotes, ChatCircle, X } from "phosphor-svelte";
	import { toast } from "svelte-sonner";

    export let event: NDKEvent;

    function closeHighlight() {
        $activeSelection = null;
    }

    async function createHighlight() {
        const text = getTextFromSelection($activeSelection);
        console.log({text})
        if (!$activeSelection) return;
        if (!event) return;
        
        return await createHighlightFromSelection($activeSelection, event);
    }

    async function highlight() {
        const hl = await createHighlight();
        if (!hl) return;
        hl.publish();

        toast.success("Highlight saved", {
            // action: {
            //     label: "Open",
            //     onClick: () => {
            //         $layout.footer!.props!.highlight = hl;
            //     }
            // }
        })
    }

    async function quote() {
        const hl = await createHighlight();
        if (!hl) return;
        await hl.sign();
        openModal(QuoteModal, {
            event: hl,
            onPublish: () => {
                hl.publish();
            }
        });
    }

    async function comment() {
        const hl = await createHighlight();
        if (!hl) return;
        await hl.sign();
        openModal(NewPostModal, {
            replyTo: hl,
            onPublish: () => {
                hl.publish();
            }
        });
    }
</script>

<div class="flex flex-col gap-6 w-full">
    {#if !$activeSelection || $activeSelection.length < 5}
        <div class="flex flex-row gap-4 items-center">
            <span class="text-sm text-gray-500">Select text to highlight</span>
            <X class="w-4 h-4 text-gray-500" />
        </div>
    {:else}
        <div class="flex flex-row justify-between w-full">
            <div class="flex flex-row justify-between w-full">
                <div class="flex flex-row gap-4">
                    <Button variant="accent" class="flex flex-row gap-2 w-fit h-fit items-center" on:click={highlight}>
                        <HighlightIcon class="w-6 h-6" />
                        <span>Highlight</span>
                    </Button>

                    <Button variant="transparent" class="flex flex-row gap-2 w-fit h-fit items-center" on:click={quote}>
                        <Quotes class="w-6 h-6" />
                        <span class="max-sm:hidden">Quote</span>
                    </Button>
                    <Button variant="transparent" class="flex flex-row gap-2 w-fit h-fit items-center" on:click={comment}>
                        <ChatCircle class="w-6 h-6" weight="fill" />
                        <span class="max-sm:hidden">Comment</span>
                    </Button>
                </div>
            </div>
            <Button variant="ghost" class="flex flex-row gap-2 w-fit h-fit items-center" on:click={closeHighlight}>
                <X class="w-6 h-6" />
            </Button>
        </div>
    {/if}
</div>