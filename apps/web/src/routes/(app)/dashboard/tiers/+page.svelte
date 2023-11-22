<script lang="ts">
    import Input from '$components/Forms/Input.svelte';
	import PageTitle from "$components/Page/PageTitle.svelte";
	import { Avatar, Name, Textarea, ndk, newToasterMessage, user } from "@kind0/ui-common";
	import { Pencil, X } from 'phosphor-svelte';
	import { NDKEvent, type NostrEvent } from '@nostr-dev-kit/ndk';
	import { getUserSupportPlansStore, startUserView } from '$stores/user-view';
	import { onMount } from 'svelte';
	import TierHeader from '$components/TierHeader.svelte';

    onMount(() => {
        startUserView($user);
    })

    const currentTiers = getUserSupportPlansStore();

    let tiers: Tier[] = [];
    let terms: string[] = ["monthly"];
    const possibleTerms = ["monthly", "quarterly", "yearly"];
    let selectedTerm: string = "monthly";
    let currency = "USD";

    function addTerm(term: string) {
        terms = [...terms, term];
    }

    function removeTerm(term: string) {
        terms = terms.filter(t => t !== term);
    }

    type Tier = {
        name: string;
        description: string;
        amounts: Record<string, string>;
        image: string;
        editName?: boolean;
        editAmount?: boolean;
        ediImage?: string;
        editDescription?: boolean;
    };

    function addTier() {
        let name = "F";
        // add the letter "A" by the the number of tiers there are
        for (let i = 0; i < tiers.length+1; i++) {
            name += "a";
        }

        name += "ns";

        tiers = [...tiers, {
            name,
            description: "Blah",
            image: "https://c10.patreonusercontent.com/4/patreon-media/p/reward/5573766/fe0d9353b56a447586507118071bb33c/eyJ3Ijo0MDB9/1.jpg?token-time=2145916800&token-hash=qbzX7mOVIcgAeYnH_tHB2ARAEWIbH98YPPdjIpahYh8%3D",
            amounts: {
                monthly: "10",
                quarterly: "30",
                yearly: "100",
            },
        }];
    }

    function removeTier(tier: Tier) {
        tiers = tiers.filter(t => t !== tier);
    }

    async function saveTiers() {
        // if there are no terms, alert
        if (terms.length === 0) {
            newToasterMessage("No terms available", "error");
            return;
        }

        if (tiers.length === 0) {
            newToasterMessage("No tiers to save");
            return;
        }

        for (const tier of tiers) {
            const amountTags = Object.entries(tier.amounts).map(([cadence, amount]) => [ "amount", amount, currency, cadence ]);
            const tierEvent = new NDKEvent($ndk, {
                kind: 7002,
                content: tier.description,
                tags: [
                    [ "title", tier.name ],
                    ...amountTags
                ]
            } as NostrEvent);

            if (tier.image) tierEvent.tags.push(["image", tier.image]);

            await tierEvent.publish();

            console.log(tierEvent.rawEvent());
        }
    }
</script>

<div class="flex flex-col gap-10 mx-auto max-w-prose">
    <PageTitle title="Support Tiers">
        <div class="flex flex-row gap-2">
            <!-- <button on:click={preview} class="button button-primary">Preview</button>
            <button on:click={preview} class="button button-primary">Save Draft</button> -->
            <button on:click={addTier} class="button px-10">Add new tier</button>
            <button on:click={saveTiers} class="button px-10">Save</button>
        </div>
    </PageTitle>
    <div class="mx-auto w-fit">
        <div class="px-12 pt-6 pb-10 bg-white rounded-3xl flex-col justify-start items-center gap-6 inline-flex w-full">
            <TierHeader user={$user} />
            <div class="justify-center items-center inline-flex">
                {#if terms.length === 0}
                    add at least one term
                {:else}
                    {#each terms as term}
                        <button
                            class="px-2.5 py-1 rounded-full justify-center items-center flex"
                            class:bg-zinc-100={term === selectedTerm}
                            on:click={() => selectedTerm = term}
                        >
                            <div class="text-center text-black text-[15px] font-medium">{term}</div>
                            <button class="btn btn-circle btn-ghost btn-xs ml-2" on:click={() => removeTerm(term)}>
                                <X color="black" class="text-sm" />
                            </button>
                        </button>
                    {/each}
                {/if}
                <div class="dropdown">
                    <button tabindex="0" class="button">+</button>
                    <ul tabindex="0" class="dropdown-content menu !bg-white">
                        {#each possibleTerms as term}
                            {#if !terms.includes(term)}
                                <li><button class="text-black" on:click={() => addTerm(term)}>
                                    {term}
                                </button></li>
                            {/if}
                        {/each}
                    </ul>
                </div>
            </div>
            <div class="justify-start items-start gap-4 inline-flex overflow-y-auto max-w-prose">
                {#each tiers as tier}
                    <div class="card card-compact full-image !rounded-3xl">
                        <figure on:click={() => {tier.image = prompt("Enter new URL")}}>
                            <img src={tier.image} alt="Tier Image" />
                        </figure>
                        <div class="card-body self-stretch p-4 bg-neutral-100 justify-between items-start flex-col min-w-[250px] min-h-[300px] gap-4 inline-flex w-full h-full">
                            <div class="flex flex-col gap-4">
                                <div class="flex-col justify-start items-start gap-2 flex w-full">
                                    <div class="text-black text-2xl font-medium w-full items-start">
                                        {#if !tier.editName}
                                            <button class="flex group flex-row justify-between items-center w-full" on:click={() => tier.editName = true}>
                                                {tier.name}
                                                <Pencil color="black" class="text-lg opacity-0 group-hover:opacity-100 transition-all duration-100" />
                                            </button>
                                        {:else}
                                            <Input
                                                bind:value={tier.name}
                                                class="w-64 !bg-transparent text-2xl"
                                                on:keyup={(k) => {
                                                    if (k.key === "Enter") {
                                                        tier.editName = false;
                                                    }
                                                }}
                                            />
                                        {/if}
                                    </div>
                                    {#if !tier.editAmount}
                                        <button class="flex group flex-row justify-between items-center w-full" on:click={() => tier.editAmount = true}>
                                            <div class="text-center text-black text-[15px] font-medium">$
                                                {tier.amounts[selectedTerm]}
                                            /{selectedTerm}</div>
                                            <Pencil color="black" class="text-lg opacity-0 group-hover:opacity-100 transition-all duration-100" />
                                        </button>
                                    {:else}
                                        <button class="flex flex-row justify-between items-center w-full" on:click={() => tier.editAmount = true}>
                                            <div class="text-center text-black text-[15px] font-medium">
                                                <Input
                                                    bind:value={tier.amounts[selectedTerm]}
                                                    class="w-64 !bg-transparent"
                                                    on:keyup={(k) => {
                                                        if (k.key === "Enter") {
                                                            tier.editAmount = false;
                                                        }
                                                    }}
                                                />
                                            </div>
                                        </button>
                                    {/if}
                                </div>
                                <div class="flex-col justify-start items-start gap-4 flex w-full">
                                    {#if !tier.editDescription}
                                        <button class="flex group flex-row justify-between items-center w-full" on:click={() => tier.editDescription = true}>
                                            <div class="text-center text-black text-[15px] font-medium">
                                                {@html tier.description}
                                            </div>
                                            <Pencil color="black" class="text-lg opacity-0 group-hover:opacity-100 transition-all duration-100" />
                                        </button>
                                    {:else}
                                        <Textarea
                                            bind:value={tier.description}
                                            on:blur={() => tier.editDescription = false }
                                            class="w-full !bg-transparent border border-neutral-800 rounded-xl rounded-t-none resize-none text-lg text-black tracking-widest" />
                                    {/if}

                                </div>
                            </div>


                            <button class="button button-primary w-full self-end" on:click={() => removeTier(tier)}>Remove</button>
                        </div>
                    </div>
                {/each}
            </div>
        </div>
    </div>
</div>