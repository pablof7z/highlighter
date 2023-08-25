<script lang="ts">
	import DvmListItem from '$components/dvms/DvmListItem.svelte';
	import Nip89Tool from '$components/dvms/Nip89Tool/Nip89Tool.svelte';
    import ndk from '$stores/ndk';
	import type { NDKEvent } from '@nostr-dev-kit/ndk';
    import { appHandlers } from "$stores/nip89";

    const dvmPubkeys = new Set<string>();

    $: $appHandlers.forEach(dvm => dvmPubkeys.add(dvm.pubkey));

    const unannouncedDvms = $ndk.storeSubscribe<NDKEvent>({
        kinds: [7000, 65001]
    });

    let unannouncedDvmsEvents = new Map<string, NDKEvent>();

    $: if ($unannouncedDvms) {
        $unannouncedDvms.forEach((e) => {
            if (!unannouncedDvmsEvents.has(e.pubkey)) {
                unannouncedDvmsEvents.set(e.pubkey, e);
                unannouncedDvmsEvents = unannouncedDvmsEvents;
            }
        })
    }

    let showNip89Tool = false;
    let showUnlistedDvms = false;
</script>

<div class="max-w-5xl mx-auto flex flex-col gap-8">


    <div class="mx-auto flex flex-col gap-4">
        <h1 class="
            text-7xl text-center font-black
            bg-clip-text !text-transparent bg-gradient-to-r from-gradient3 to-gradient4
        ">Data Vending Machines</h1>
        <div class="text-2xl text-base-100-content font-extralight text-center">
            Programs serving and processing job requests on Nostr.
        </div>
        <div class="text-lg text-base-100-content font-extralight text-center">
            Each DVM can support an ever-expanding range of job types.
        </div>

        <button class="btn btn-outline btn-accent px-8 !rounded-full text-base-100-content self-center" on:click={() => showNip89Tool = !showNip89Tool}>
            List your DVM with NIP-89
        </button>
    </div>

    {#if showNip89Tool}
        <Nip89Tool on:cancel={() => showNip89Tool = false} on:done={() => showNip89Tool = false} />
    {:else}
        <div class="grid md:grid-cols-3 px-2 md:px-0 gap-4 mt-10">
            {#each $appHandlers as dvm (dvm.id)}
                <DvmListItem {dvm} />
            {/each}
        </div>

        <hr>

        <div class="max-w-prose mx-auto flex flex-col gap-4">
            <h1 class="text-3xl text-center font-semibold">
                {unannouncedDvmsEvents.size}
                Unannounced DVMs
            </h1>
            <h2 class="text-center leading-loose">These are DVMs that have been seen acting in the wild but that have not create a NIP-89 record.</h2>
        </div>

        <button class="btn btn-ghost btn-outline btn-lg self-center"
            on:click={() => showUnlistedDvms = !showUnlistedDvms}
        >
            {#if showUnlistedDvms}
                Hide
            {:else}
                Show
            {/if} unlisted DVMs
        </button>

        {#if unannouncedDvmsEvents.size > 0 && showUnlistedDvms}
            <div class="flex flex-col divide-y divide-base-300 mt-10 max-w-prose mx-auto">
                {#each Array.from(unannouncedDvmsEvents.values()) as dvm (dvm)}
                    {#if !dvmPubkeys.has(dvm.pubkey)}
                        <DvmListItem {dvm} />
                    {/if}
                {/each}
            </div>
        {/if}
    {/if}
</div>