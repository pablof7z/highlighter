<script lang="ts">
	import FailedEventModals from "$modals/FailedEventModals.svelte";
	import { failedPublishEvents } from "$stores/events";
	import { openModal } from "$utils/modal";
	import { newToasterMessage } from "$stores/toaster.js";
	import { Warning } from "phosphor-svelte";

    function showErrors() {
        openModal(FailedEventModals);
    }

    let failedCount = $failedPublishEvents.size
    
    $: if ($failedPublishEvents.size !== failedCount) {
        if ($failedPublishEvents.size > failedCount) {
            newToasterMessage("Failed to publish", "error");
        }

        failedCount = $failedPublishEvents.size;
    }
</script>

<button class="text-center items-center flex flex-col" on:click={showErrors}>
{#if failedCount > 0}
    <Warning size={24} class="text-error" />
    <span class="badge">
        <span class="indicator-item rounded-full bg-accent text-white flex items-center justify-center text-xs w-5 h-5">
            {failedCount}
        </span>
    </span>
{/if}
</button>