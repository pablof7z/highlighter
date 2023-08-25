<script lang="ts">
	import type { NDKDVMRequest, NDKEvent } from "@nostr-dev-kit/ndk";
	import { openModal } from "svelte-modals";
    import JobRequestEditorModal from "$modals/JobRequestEditorModal.svelte";
    import { Plus } from "phosphor-svelte";
	import { slide } from "svelte/transition";
	import type { Readable } from "svelte/motion";
	import type { NDKEventStore } from "@nostr-dev-kit/ndk-svelte";

    export let expand = false;

    let hover = false;

    setTimeout(() => {
        hover = false;
    }, 2500);
</script>

<button
    class="
        btn-normal group btn btn-sm inline-block flex w-fit min-w-[32px] flex-row items-center
        border border-gradient3 text-gradient3
        !rounded-full !bg-base-300 from-gradient3
        to-gradient4
        p-1 font-normal
        transition-all
        duration-200
        {(hover || expand) ? "bg-gradient-to-r px-4 !text-white" : ""}
    "
    on:mouseover={() => (hover = true)}
    on:mouseout={() => (hover = false)}
    on:click
>
    <Plus size="1rem" />
    {#if hover || expand}
        <span class="line-clamp-1 whitespace-nowrap" transition:slide|local={{ axis: 'x' }}>
            Add input
        </span>
    {/if}
</button>