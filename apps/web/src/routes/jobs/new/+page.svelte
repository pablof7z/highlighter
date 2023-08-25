<script lang="ts">
	import type { NDKDVMRequest } from "@nostr-dev-kit/ndk";
    import JobRequestEditor from "$components/jobs/JobRequestEditor/JobRequestEditor.svelte";
	import { goto } from "$app/navigation";

    let jobs: NDKDVMRequest[] = [];
    let jobRequest: NDKDVMRequest | undefined;
    let showNewJobRequest = true;

    function jobCreated() {
        if (jobRequest) jobs.push(jobRequest);
        jobs = jobs;
        jobRequest = undefined;
        showNewJobRequest = false;
        goto(`/jobs/${jobs[0].encode()}`);
    }
</script>

<div class="flex flex-col gap-8">
    <div class="flex flex-col divide-y divide-base-300">
        {#if showNewJobRequest}
            <div class="card">
                <JobRequestEditor
                    bind:jobRequest
                    {jobs}
                    on:created={jobCreated}
                />
            </div>
        {:else}
            <button
                class="btn btn-primary self-start"
                on:click={() => showNewJobRequest = true}
            >
                Add new job request
            </button>
        {/if}
    </div>
</div>

<style>
    h3 {
        @apply text-lg text-base-100-content font-semibold;
    }
</style>
