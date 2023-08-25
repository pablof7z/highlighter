<script lang="ts">
    import { NDKKind, type NDKDVMRequest, NDKTranscriptionDVM } from "@nostr-dev-kit/ndk";

    export let job: NDKDVMRequest;

    let Component: any;
    let _job: any;

    async function loadComponent() {
        switch (job.kind) {
            case NDKKind.DVMReqTextExtraction: {
                const module = await import("./JobTextExtraction.svelte");
                Component = module.default; // Access the default export
                _job = NDKTranscriptionDVM.from(job);
                break;
            }
            case NDKKind.DVMReqTextSummarization: {
                const module = await import("./JobSummarization.svelte");
                Component = module.default; // Access the default export
                _job = NDKTranscriptionDVM.from(job);
                break;
            }
        }
    }

    loadComponent();

    async function publish() {
        await job.publish();
    }
</script>

{#if Component}
    <div class="card">
        <div class="card-body">

            {#if !job.id}
                <button class="btn btn-ghost btn-sm self-end" on:click={publish}>
                    Publish
                </button>
            {/if}

            <svelte:component this={Component} job={_job} />
        </div>
    </div>
{/if}
