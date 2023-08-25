<script lang="ts">
	import type { NDKDVMRequest, NDKEvent } from "@nostr-dev-kit/ndk";
	import { openModal } from "svelte-modals";
    import JobRequestEditorModal from "$modals/JobRequestEditorModal.svelte";
    import { Plus } from "phosphor-svelte";
	import { slide } from "svelte/transition";
	import type { NDKEventStore } from "@nostr-dev-kit/ndk-svelte";
    import { addJobButtonsSeen } from "$stores/settings";

    export let jobRequest: NDKDVMRequest
    export let dependentJobs: NDKEventStore<NDKEvent>;

    let hover = $addJobButtonsSeen < 1000;
    $addJobButtonsSeen++;

    setTimeout(() => {
        hover = false;
    }, 2500);


</script>

<button
    class="
        btn-normal group btn btn-sm inline-block flex w-fit min-w-[32px] flex-row items-center
        !rounded-full !bg-base-300 from-gradient3
        to-gradient4
        p-1 font-normal
        transition-all
        px-3
        duration-200
        {hover ? "bg-gradient-to-r text-white" : ""}
    "
    on:mouseover={() => (hover = true)}
    on:mouseout={() => (hover = false)}
    on:click={() => {
        openModal(JobRequestEditorModal, {
            suggestedJobRequestInput: jobRequest,
            jobs: [...$dependentJobs, jobRequest]
        });
    }}
>
    <Plus size="1rem" />
    {#if hover}
        <span class="line-clamp-1 whitespace-nowrap" transition:slide|local={{ axis: 'x' }}>
            Add job
        </span>
    {/if}
</button>