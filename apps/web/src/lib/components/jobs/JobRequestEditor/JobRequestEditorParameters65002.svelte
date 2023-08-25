<script lang="ts">
    import type { NDKDvmParam } from "@nostr-dev-kit/ndk";

    export let params: NDKDvmParam[] = [];

    function updateRange() {
        params = params.filter(param => param[0] !== "range");

        if (rangeStart && rangeEnd) {
            params.push([ "range", rangeStart, rangeEnd ]);
            params = params;
        }
    }

    let rangeStart: string | undefined;
    let rangeEnd: string | undefined;
</script>

<p>
    Range (for audio/video)
    <span class="badge badge-neutral">Optional</span>
</p>
<div class="flex flex-row gap-2">
    <input type="number" class="input input-bordered" placeholder="Starting second" bind:value={rangeStart} on:change={updateRange} />
    <input type="number" class="input input-bordered" placeholder="Finishing second" bind:value={rangeEnd} on:change={updateRange} />
</div>
