    <script lang="ts">
	import { CaretLeft, Eye, Eye, Timer, UsersThree } from "phosphor-svelte";
    import { event, view, type, status, View, currentDraftItem, selectedTiers, preview, publishAt, selectedTiers } from "$stores/post-editor";
	import { closeModal, openModal } from '$utils/modal';
	import ScheduleModal from '$modals/ScheduleModal.svelte';
	import { appMobileView } from '$stores/app';
	import { Actions, ActionsButton, ActionsGroup, ActionsLabel, Button, Link, Toolbar } from 'konsta/svelte';
    import { NavbarBackLink } from 'konsta/svelte';
	import TiersLabel from "$components/Forms/TiersLabel.svelte";

    export let onSaveDraft: () => void;
    export let onPublish: () => void;
    export let onNext: () => void;
    export let showEdit = true;
    export let showSaveDraft = true;
    export let showPreview = true;
    export let showPublish = true;
    export let showAudience = true;
    export let showNext = false;
    export let publishing = false;

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
            cta: "Continue",
            action,
            onSchedule: async (timestamp: number) => {
                $publishAt = new Date(timestamp);
                closeModal();
            }
        });
    }

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
<div class="flex flex-row justify-between h-full w-full items-center py-2 {$$props.containerClass??""}" class:hidden={$view === "published"}>
    <div class="flex flex-row gap-4 self-end">
        {#if showEdit && $view !== "edit"}
            <button class="button-black" on:click={() => $view = 'edit'}>
                <CaretLeft class="inline mr-2" size={20} />
                Edit
            </button>
        {/if}
    
        {#if showAudience && !['audience', 'edit-preview', 'view-preview'].includes($view)}
            <button class="button-black" on:click={() => $view = 'audience'}>
                <UsersThree class="inline mr-2" size={20} />
                <TiersLabel tiers={$selectedTiers} />
            </button>
        {/if}

        {#if showPreview &&  !['audience', 'view-preview', 'edit-preview'].includes($view)}
            <button class="button-black" on:click={togglePreview}>
                <Eye class="inline mr-2" size={20} />
                Preview
            </button>
        {/if}
        
        {#if $status.length > 0}
            <div></div>
            <!-- <div class="text-sm font-normal flex flex-row gap-2 items-center text-neutral-500">
                <div class="loading loading-sm loading-ring"></div>
                <span class="max-sm:hidden">{$status[0]}</span>
            </div> -->
        {/if}
    </div>

    <div class="flex flex-row gap-4 self-end">
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
            <div class="flex flex-row flex-nowrap gap-2">
                <button class="button-black rounded-full" on:click={schedule}>
                    <Timer size={24} />
                </button>
                <button class="button" on:click={onPublish} disabled={publishing}>
                    {#if publishing}
                        <span class="loading loading-sm"></span>
                    {/if}
                    
                    {#if $publishAt}
                        Schedule
                    {:else}
                        Publish
                    {/if}
                </button>
            </div>
        {/if}

        {#if showNext}
            <div class="flex flex-row flex-nowrap gap-2">
                <button class="button" on:click={onNext} disabled={publishing}>
                    Next
                </button>
            </div>
        {/if}
    </div>
</div>
{/if}