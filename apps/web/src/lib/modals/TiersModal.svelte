<script lang="ts">
	import TierList from "$components/Creator/TierList.svelte";
    import ModalShell from "$components/ModalShell.svelte";
	import { closeModal } from '$utils/modal';
	import { PlusCircle } from "phosphor-svelte";

    export let forceSave = false;
</script>

<ModalShell
    title="Support Tiers"
    class="w-full max-w-2xl flex flex-col items-stretch overflow-y-auto max-h-[70vh]"
>
    <TierList
        redirectOnSave={false}
        bind:forceSave
        on:saved={closeModal}
        skipButtons
    />

    <svelte:fragment slot="footer">
        <button class="button button-black py-3 w-fit">
            <PlusCircle class="w-6 h-6 inline mr-2" />
            New Tier
        </button>

        <div class="grow"></div>
        
        <button
            class="button button-black py-3 w-fit self-center"
            on:click|stopPropagation|preventDefault={closeModal}
        >
            Close
        </button>

        <button class="button px-6" on:click={() => forceSave = true}>
            Save
        </button>
    </svelte:fragment>
</ModalShell>