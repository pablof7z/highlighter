<script lang="ts">
	import NewTier from '$components/Forms/NewTier.svelte';
	import PageTitle from "$components/Page/PageTitle.svelte";
	import NewItemModal from "$modals/NewItemModal.svelte";
	import { Avatar, Name, user } from "@kind0/ui-common";
	import { openModal } from "svelte-modals";

    function publish() {
        openModal(NewItemModal);
    }
</script>

<div class="flex flex-col gap-10 mx-auto max-w-prose">
    <PageTitle title="Creator Dashboard">
        <div class="flex flex-row gap-2">
            <!-- <button on:click={preview} class="button button-primary">Preview</button>
            <button on:click={preview} class="button button-primary">Save Draft</button> -->
            <button on:click={publish} class="button px-10">Publish</button>
        </div>
    </PageTitle>

    <div class="flex flex-row items-center gap-4">
        <Avatar user={$user} class="w-32 h-32" />

        <div class="flex flex-col gap-2">
            <Name user={$user} class="text-xl font-semibold text-white" />
            <div class="text-white text-opacity-60 text-sm font-normal leading-6">0 subscriber  ·  0 paying supporters</div>
        </div>
    </div>
</div>