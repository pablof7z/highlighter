<script lang="ts">
	import type { NDKDvmParam, NDKEvent } from '@nostr-dev-kit/ndk';
    import JobRequestEditorParameters65002 from './JobRequestEditorParameters65002.svelte';
	import type { Nip90Param } from '$utils/nip90';
	import ParamInput from './ParamInput.svelte';

    export let params: NDKDvmParam[] = [];
    export let kind: number;
    export let nip89Events: NDKEvent[];

    let dvmParams: Record<string, Nip90Param> = {};

    nip89Events?.forEach((nip89Event) => {
        try {
            const content = JSON.parse(nip89Event.content);
            const nip90Params: Record<string, Nip90Param>[] = content.nip90Params;

            // go through each param and add it to the dvmParams object so that if there are multiple values inside the Nip90Param for the same name, all of them are added
            if (nip90Params) {
                for (const [name, params] of Object.entries(nip90Params)) {
                    if (dvmParams[name] && params.values) {
                        dvmParams[name].values ??= [];
                        dvmParams[name].values!.push(...params.values);
                    } else {
                        dvmParams[name] = params;
                    }
                }
            }

            dvmParams = dvmParams;
        } catch (e) {
            console.log(e)
        }
    })

    function updateTags() {
        params = [];
        for (const [ name, value ] of Object.entries(paramValues)) {
            if (value && value.length > 0) {
                const p: NDKDvmParam = [name, value[0], ...value.slice(1)];
                params.push(p);
            }
        }
        params = params;
    }

    let paramValues: Record<string, string[]> = {};
</script>

<div class="flex flex-col gap-2 mb-4">
    {#each Object.keys(dvmParams) as paramName}
        {#if dvmParams[paramName].required}
            <ParamInput
                name={paramName}
                bind:value={paramValues[paramName]}
                values={dvmParams[paramName].values || []}
                on:change={updateTags}
            />
        {/if}
    {/each}

    {#if kind === 5000}
        <JobRequestEditorParameters65002 bind:range={paramValues["range"]} on:change={updateTags} />
    {/if}
</div>

<details class="collapse collapse-arrow border border-base-300 bg-base-200 join-item">
    <summary class="collapse-title">
        <div class="flex flex-row gap-2 items-end">
            <h3>
                Parameters
                {#if Object.keys(dvmParams).length > 0}
                    <span class="badge badge-neutral">{Object.keys(dvmParams).length}</span>
                {/if}
            </h3>
            <span class="font-thin text-base opacity-50">
                Specify additional parameters
            </span>
        </div>
    </summary>

    <div class="collapse-content">
        <div class="flex flex-col gap-2">
            {#each Object.keys(dvmParams) as paramName}
                <ParamInput
                    name={paramName}
                    bind:value={paramValues[paramName]}
                    values={dvmParams[paramName].values || []}
                    on:change={updateTags}
                />
            {/each}
        </div>
    </div>
</details>


