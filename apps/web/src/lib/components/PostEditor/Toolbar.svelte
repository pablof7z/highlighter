    <script lang="ts">
	import PublishConfirmationModal from './PublishConfirmationModal.svelte';
	import { CaretDown, CaretLeft, CaretRight, Notches, PaperPlane, Timer } from "phosphor-svelte";
    import { view } from "$stores/post-editor";
	import { openModal } from "svelte-modals";

    function previewAndPublish() {
        openModal(PublishConfirmationModal)
    }

    type Entry = { label: string, value: string };

    let back: Entry | undefined;
    let next: Entry | undefined;

    $: switch ($view) {
        case "edit": back = undefined; next = {label: "Continue", value: "meta"}; break;
        case "meta": back = {label: "Back to Edit", value: "edit"}; next = {label: 'Continue', value: "audience"}; break;
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
</script>

<div class="flex flex-row justify-between h-full w-full items-center">
    {#if back}
        <button class="button button-black" on:click={backClicked}>
            <CaretLeft size={24} />
            {back.label}
        </button>
    {:else}
        <div></div>
    {/if}

    <div class="flex flex-row gap-4 self-end">
        {#if next}
            <button class="button" on:click={nextClicked}>
                {next.label}
                <CaretRight size={24} />
            </button>
        {/if}
    </div>
</div>