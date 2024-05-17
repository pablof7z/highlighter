    <script lang="ts">
	import { component } from './../../../../.svelte-kit/output/server/nodes/0.js';
	import { Thread, publishThread } from '$utils/thread.js';
	import PublishConfirmationModal from './PublishConfirmationModal.svelte';
	import { CaretLeft, CaretRight, Timer } from "phosphor-svelte";
    import { event, view, type, status, View, currentDraftItem, selectedTiers, preview } from "$stores/post-editor";
	import { openModal } from '$utils/modal';
	import { debugMode } from '$stores/session';
    import { getUserSubscriptionTiersStore } from '$stores/user-view';
	import { goto } from '$app/navigation';
	import ScheduleModal from '$modals/ScheduleModal.svelte';
	import { TierSelection } from '$lib/events/tiers';
	import { getAuthorUrl } from '$utils/url';
	import currentUser from '$stores/currentUser';
	import { appMobileView } from '$stores/app';
	import { pageHeader, pageNavigationOptions, resetLayout } from '$stores/layout';
	import MobileToolbarHelper from './MobileToolbarHelper.svelte';

    export let onSaveDraft: () => void;

    function previewAndPublish() {
        openModal(PublishConfirmationModal)
    }

    type Entry = { label: string, value: string };

    let back: Entry | undefined;
    let next: Entry | undefined;

    const tiers = getUserSubscriptionTiersStore();

    let modeBeforePreview: View | undefined;
    function togglePreview() {
        if ($view !== "view-preview") {
            modeBeforePreview = $view;
            $view = "view-preview";
        } else {
            $view = modeBeforePreview || "edit";
            modeBeforePreview = undefined;
        }
    }

    $: switch ($view) {
        case "edit":
            back = undefined;
            next = {label: "Continue", value: "meta"};
            switch ($type) {
                case "note": {
                    next = {label: "Continue", value: "audience"};
                    break;
                }

                case "thread": {
                    next = {label: "Continue", value: "schedule"};
                    break;
                }
            }
            break;
        case "view-preview":
            back = {label: "Back to Edit", value: "edit"};
            next = {label: "Continue", value: "edit-preview"};
            break;
        case "meta": {
            back = {label: "Back to Edit", value: "edit"};
            if ($tiers.length > 0) next = {label: "Continue", value: "audience"};
            else next = {label: 'Continue', value: "schedule"};
            break;
        }
        case "edit-preview": back = {label: 'Back', value: "audience"}; next = {label: 'Continue', value: "schedule"}; break;
        case "audience": back = {label: 'Back', value: "meta"}; next = {label: 'Continue', value: "schedule"}; break;
    }

    function backClicked() {
        if (back) $view = back.value as any;
    }

    function nextClicked() {
        if (next?.value === "schedule") {
            previewAndPublish();
        } else if (next) $view = next.value as any;
    }

    let publishing = false;
    
    async function _publishThread() {
        if (!($event instanceof Thread)) {
            throw 'not a thread';
        }

        let tiers: TierSelection | undefined = $selectedTiers;

        // if this is a kind 1 no tiers
        if ($event.items[0].event.kind === 1) {
            tiers = undefined;
        }
        
        publishing = true;

        try {
            await publishThread(
                $event,
                undefined,
                tiers
            );

            goto(await getAuthorUrl($currentUser!));
        } finally {
            publishing = false;
        }
    }

    async function scheduleThread() {
        if (!($event instanceof Thread)) {
            throw 'not a thread';
        }

        const length = $event.items.length;

        let action = "Thread will be published";

        if (length === 1) {
            action = "Post will be published";
        }
        
        openModal(ScheduleModal, {
            action,
            onSchedule: async (timestamp: number) => {
                await publishThread(
                    $event as Thread,
                    new Date(timestamp),
                    $selectedTiers
                );
            }
        });
    }

    let hasPreview = false;
    $: hasPreview = ["article", "thread"].includes($type!) 

    let hasStatus = $status.length;
    $: hasStatus = $status.length;

    // if we are in mobile view, we set the left and right buttons instead of rendering here
    $: if ($appMobileView) {
        $pageHeader = {};
        if (back) {
            $pageHeader.left = {
                icon: CaretLeft,
                label: back.label,
                fn: backClicked
            };
        } else if (hasPreview) {
            $pageHeader.left = {
                component: {
                    component: MobileToolbarHelper,
                    props: {
                        onSaveDraft,
                        togglePreview
                    }
                }
            }
        }

        if (next) {
            $pageHeader.right = {
                icon: CaretRight,
                label: next.label,
                fn: nextClicked
            };
        }

        if (hasPreview) {
            $pageHeader
        }
    }
</script>

<div class="flex flex-row justify-between h-full w-full items-center" class:hidden={$view === "published"}>
    {#if back}
        <button class="button button-black truncate" on:click={backClicked}>
            <CaretLeft size={24} />
            {back.label}
        </button>
    {/if}

        {#if $status.length > 0}
            <div></div>
            <!-- <div class="text-sm font-normal flex flex-row gap-2 items-center text-neutral-500">
                <div class="loading loading-sm loading-ring"></div>
                <span class="max-sm:hidden">{$status[0]}</span>
            </div> -->
        {:else if !back}
            <div></div>
        {/if}

    {#if $debugMode}
        {$view}
    {/if}

    <div class="flex flex-row gap-4 self-end">
        {#if next}
            {#if ($type === "article" || $type === "thread")} 
                <button class="truncate" on:click={togglePreview} class:button={$view === "view-preview"}>
                    Preview
                </button>

                <button class="truncate" on:click={() => {if (onSaveDraft) onSaveDraft()}}>
                    Save Draft
                </button>
            {/if}

            {#if $type === "thread" && next.value === "schedule"}
                <button class="btn btn-circle" on:click={scheduleThread}>
                    <Timer size={24} />
                </button>

                <button class="button" on:click={_publishThread} disabled={publishing}>
                    {#if publishing}
                        <span class="loading loading-sm"></span>
                    {/if}
                    
                    Publish
                </button>
            {:else}
                <button class="button" on:click={nextClicked} disabled={$view === "view-preview"}>
                    {next.label}
                    <CaretRight size={24} />
                </button>
            {/if}
        {/if}
    </div>
</div>