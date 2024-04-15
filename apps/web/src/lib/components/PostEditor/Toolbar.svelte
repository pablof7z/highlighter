    <script lang="ts">
	import PublishConfirmationModal from './PublishConfirmationModal.svelte';
	import { CaretLeft, CaretRight } from "phosphor-svelte";
    import { view, type, status, View } from "$stores/post-editor";
	import { openModal } from "svelte-modals";
	import { debugMode } from '$stores/session';
    import { getUserSubscriptionTiersStore } from '$stores/user-view';

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
            if ($type === "note") next = {label: "Continue", value: "audience"};
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

    let hasStatus = $status.length;
    $: hasStatus = $status.length;
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
            {#if ($type === "article")}
                <button class="truncate" on:click={togglePreview} class:button={$view === "view-preview"}>
                    Preview
                </button>
            {/if}
            <button class="button" on:click={nextClicked} disabled={$view === "view-preview"}>
                {next.label}
                <CaretRight size={24} />
            </button>
        {/if}
    </div>
</div>