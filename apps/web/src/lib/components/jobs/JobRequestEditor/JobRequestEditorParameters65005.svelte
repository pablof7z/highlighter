<script lang="ts">
    import type { NDKDvmParam } from "@nostr-dev-kit/ndk";

    export let params: NDKDvmParam[] = [];

    const kindParams = ["negative_prompt", "ratio", "model"];

    function update() {
        params = params.filter(param => !kindParams.includes(param[0]));

        if (negativePrompt && negativePrompt.length > 0) {
            params.push([ "negative_prompt", negativePrompt ]);
        }

        if (ratio && ratio.length > 0) params.push([ "ratio", ratio ]);
        if (model && model.length > 0) params.push([ "model", model ]);

        params = params;
    }

    let negativePrompt: string | undefined;
    let ratio: string | undefined;
    let model: string | undefined;
</script>

<section class="params">
    <h3>Negative prompt (optional)</h3>
    <textarea class="textarea textarea-bordered w-full" placeholder="" bind:value={negativePrompt} on:change={update} />
</section>

<section class="params">
    <h3>Ratio (optional)</h3>
    <input type="string" class="input input-bordered w-24" placeholder="Ratio" bind:value={ratio} on:change={update} />
</section>

<section class="params">
    <h3>Model (optional)</h3>
    <input type="string" class="input input-bordered w-full" placeholder="Model" bind:value={model} on:change={update} />
</section>
