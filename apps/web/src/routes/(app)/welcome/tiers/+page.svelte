<script>
	import { goto } from "$app/navigation";
	import TierList from "$components/Creator/TierList.svelte";
	import MainWrapper from "$components/Page/MainWrapper.svelte";
	import MobileHeader from "$components/Page/MobileHeader.svelte";
	import PageTitle from "$components/Page/PageTitle.svelte";
	import { ArrowRight } from "phosphor-svelte";

    let saving = false;
    let forceSave = false;
</script>

<MobileHeader backButton={"/welcome"} title="Tiers">
    <button class="button flex flex-row items-center gap-2 px-6" slot="button" on:click={() => {forceSave = true}}>
        {#if saving}
            <span class="loading loading-sm"></span>
        {:else}
            Save
        {/if}
    </button>
</MobileHeader>

<MainWrapper class="p-4 pt-0 pb-24 sm:p-6">
    <PageTitle title="Tiers" />

    <div class="flex flex-col gap-8 max-w-prose">
        <TierList
            redirectOnSave={false}
            usePresetButton={true}
            bind:saving
            {forceSave}
            on:saved={() => goto("/welcome")}
        >
            <div slot="saveButton" class="flex flex-row">
                Save
            </div>
        </TierList>
    </div>
</MainWrapper>