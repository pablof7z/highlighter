<script lang="ts">
	import Subscribe from './Payment/Subscribe.svelte';
	import { currencySymbol } from "$utils/currency";
	import type { Term } from "$utils/term";
	import { Textarea, ndk } from "@kind0/ui-common";
	import { NDKKind, type NDKEvent } from "@nostr-dev-kit/ndk";
	import { Pencil } from "phosphor-svelte";
    import { createEventDispatcher, onMount } from "svelte";
	import type { Tier } from "../../routes/dashboard/tiers/tier";
	import { randomVideoThumbnail } from '$utils/skeleton';

    export let event: NDKEvent | undefined = undefined;
    export let tier: Tier;
    export let currency: string;

    export let terms: Term[] = [];

    let subscribedCount: number | undefined = undefined;

    onMount(() => {
        if (event?.sig) {
            $ndk.fetchEvents({kinds: [NDKKind.SubscriptionStart], ...event.filter()}).then((events) => {
                subscribedCount = events.size;
            });
        }
    })

    const dispatch = createEventDispatcher();
    const defaultImage = randomVideoThumbnail();
</script>

<div class="card card-compact full-image !rounded-3xl w-80 flex-none">
    <figure class="relative group">
        <img src={tier.image} alt="Tier Image" />
        <button class="z-50 btn btn-circle btn-black btn-sm absolute top-2 right-2 opacity-0 group-hover:opacity-100 transition-all duration-100" on:click={() => {tier.image = prompt("Enter new URL") || defaultImage}}>
            <Pencil color="white" class="" />
        </button>
    </figure>
    <div class="card-body self-stretch p-4 bg-neutral-100 justify-between items-start flex-col min-w-[250px] min-h-[300px] gap-4 inline-flex w-full h-full">
        <div class="flex flex-col gap-4 w-full flex-grow">
            <div class="flex-col justify-start items-start gap-2 flex w-full">
                <div class="text-black text-2xl font-normal w-full items-start">
                    <div class="flex group flex-row justify-between items-center w-full gap-2">
                        <input
                            bind:value={tier.name}
                            on:change={() => tier = tier }
                            class="w-full !bg-transparent text-2xl text-black border-none p-0"
                            placeholder="Tier name"
                        />
                        <Pencil color="black" class="text-lg opacity-0 group-hover:opacity-100 transition-all duration-100" />
                    </div>
                </div>
                {#each terms as term}
                    <div class="flex flex-row justify-between items-center w-full">
                        <div class="text-center text-black text-[15px] font-normal flex flex-row items-center">
                            <input
                            bind:value={tier.amounts[term]}
                            on:change={() => {
                                tier.amounts = {...tier.amounts};
                                tier = tier
                            }}
                            class="w-full !bg-transparent p-0 text-black border-none flex-none"
                            placeholder="Enter {term} price"
                            />
                            <span class="absolute right-4">{currencySymbol(currency)}/{term}</span>
                        </div>
                    </div>
                {/each}
            </div>
            <div class="flex-col justify-start items-start gap-4 flex w-full flex-grow">
                <Textarea
                    bind:value={tier.description}
                    on:change={() => tier = tier }
                    class="w-full !bg-transparent border-none p-0 rounded-xl rounded-t-none resize-none text-black flex-grow"
                    placeholder="Tier description"
                />
            </div>
        </div>

        {#if tier.modified && event}
            <button class="button button-primary w-full self-end" on:click={() => dispatch('save')}>
                Save
            </button>
        {:else}
            <button class="button button-primary w-full self-end flex flex-row items-center gap-1" on:click={() => dispatch('remove')}>
                {#if event}
                    Delete
                    {#if subscribedCount && subscribedCount > 0}
                        <div class="text-neutral-500 text-center shrink text-xs">
                            {subscribedCount} subscribers
                        </div>
                    {/if}
                {:else}
                    Remove
                {/if}
            </button>
        {/if}
    </div>
</div>