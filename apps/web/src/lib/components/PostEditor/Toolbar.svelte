    <script lang="ts">
	import { Thread, publishThread } from '$utils/thread.js';
	import { Eye, Timer } from "phosphor-svelte";
    import { event, view, type, status, View, currentDraftItem, selectedTiers, preview } from "$stores/post-editor";
	import { openModal } from '$utils/modal';
    import { getUserSubscriptionTiersStore } from '$stores/user-view';
	import { goto } from '$app/navigation';
	import ScheduleModal from '$modals/ScheduleModal.svelte';
	import { TierSelection } from '$lib/events/tiers';
	import { getAuthorUrl } from '$utils/url';
	import currentUser from '$stores/currentUser';
	import { appMobileView } from '$stores/app';
	import { Actions, ActionsButton, ActionsGroup, ActionsLabel, Button, Link, Toolbar } from 'konsta/svelte';
    import { NavbarBackLink } from 'konsta/svelte';

    export let onSaveDraft: () => void;
    export let onPublish: () => void;
    export let showEdit = true;
    export let showSaveDraft = true;
    export let showPreview = true;
    export let showSchedule = true;
    export let showPublish = true;
    export let showAudience = true;
    export let publishing = false;

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

    async function schedule() {
        let action: string;

        if ($type === "thread") {
            const length = $event.items.length;

            action = "Thread will be published";

            if (length === 1) {
                action = "Post will be published";
            }
        } else {
            action = "Publish"
        }
        
        openModal(ScheduleModal, {
            title: `Schedule`,
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
    // $: if ($appMobileView) {
    //     $pageHeader = {};
    //     if (back) {
    //         $pageHeader.left = {
    //             icon: CaretLeft,
    //             label: back.label,
    //             fn: backClicked
    //         };
    //     } else if (hasPreview) {
    //         $pageHeader.left = {
    //             component: {
    //                 component: MobileToolbarHelper,
    //                 props: {
    //                     onSaveDraft,
    //                     togglePreview
    //                 }
    //             }
    //         }
    //     }

    //     if (next) {
    //         $pageHeader.right = {
    //             icon: CaretRight,
    //             label: next.label,
    //             fn: nextClicked
    //         };
    //     }

    //     if (hasPreview) {
    //         $pageHeader
    //     }
    // }

    let actionsOneOpened = false;

    function showPublishModal() {
        actionsOneOpened = true;
    }
</script>

{#if $appMobileView}
    <Toolbar top>
        <div class="left flex flex-row items-center gap-4">
            {#if showEdit && $view !== "edit"}
                <NavbarBackLink onClick={() => $view = 'edit'} />
            {:else}
                {#if showPreview}
                    <Link onClick={() => $view = "view-preview"}>
                        <Eye />
                    </Link>
                {/if}
                {#if showAudience}
                    <Link onClick={() => $view = "audience"}>
                        Audience
                    </Link>
                {/if}
            {/if}
        </div>

        <div class="right">
            {#if showPublish}
                <Link onClick={showPublishModal} disabled={publishing}>
                    Next
                </Link>
            {/if}
        </div>
    </Toolbar>

    <Actions
        opened={actionsOneOpened}
        onBackdropClick={() => (actionsOneOpened = false)}
    >
        <ActionsGroup>
        <ActionsButton onClick={() => (actionsOneOpened = false)} bold>
            Publish
        </ActionsButton>
        <ActionsButton onClick={() => (actionsOneOpened = false)}>
            Schedule
        </ActionsButton>
        <ActionsButton onClick={() => (actionsOneOpened = false)}>
            Cancel
        </ActionsButton>
        </ActionsGroup>
    </Actions>
{:else}
<div class="sm:-translate-x-[calc(var(--navbar-collapsed)/2)] flex flex-row justify-between h-full w-full items-center py-2 {$$props.containerClass??""}" class:hidden={$view === "published"}>
        {#if showEdit && $view !== "edit"}
            <button class="truncate" on:click={() => $view = 'edit'}>
                Back to edit
            </button>
        {/if}
    
        {#if showAudience && $view !== 'audience'}
            <button class="truncate" on:click={() => $view = 'audience'}>
                Audience
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

        {$view}

    <div class="flex flex-row gap-4 self-end">
        {#if showPreview}
            <button class="truncate" on:click={togglePreview} class:button={$view === "view-preview"}>
                Preview
            </button>
        {/if}

        <!-- {#if next}
            {#if ($type === "article" || $type === "thread")} 
                

                <button class="truncate" on:click={() => {if (onSaveDraft) onSaveDraft()}}>
                    Save Draft
                </button>
            {/if}

            {#if $type === "thread" && next.value === "schedule"}
                

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
        {/if} -->

        {#if showPublish}
            <button class="btn btn-circle" on:click={schedule}>
                <Timer size={24} />
            </button>
            <button class="button" on:click={onPublish} disabled={publishing}>
                {#if publishing}
                    <span class="loading loading-sm"></span>
                {/if}
                
                Publish
            </button>
        {/if}
    </div>
</div>
{/if}