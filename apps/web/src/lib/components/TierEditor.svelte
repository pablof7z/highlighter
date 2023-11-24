<script lang="ts">
	import type { Term } from "$utils/term";
    import Input from "$components/Forms/Input.svelte";
	import { Textarea } from "@kind0/ui-common";
	import type { NDKEvent } from "@nostr-dev-kit/ndk";
	import { Pencil } from "phosphor-svelte";
    import { createEventDispatcher } from "svelte";

    export let tier: NDKEvent | undefined = undefined;
    export let image: string | undefined = undefined;
    export let name: string | undefined = undefined;
    export let description: string | undefined = undefined;
    export let amounts: Record<string, string> | undefined = {};

    export let terms: Term[] = [];

    let tierModified = false;

    $: if (tier) {
        const tierAmounts = tier.getMatchingTags("amount").reduce((acc, tag) => {
            acc[tag[3]] = tag[1];
            return acc;
        }, {} as Record<string, string>);
        const tierAmountsJSON = JSON.stringify(tierAmounts);
        const amountsJSON = JSON.stringify(amounts);

        console.log(tierAmountsJSON, amountsJSON);

        tierModified = tier.tagValue("title") !== name
            || tier.content !== description
            || tier.tagValue("image") !== image
            || tierAmountsJSON !== amountsJSON;
    }

    if (tier) {
        name = tier.tagValue("title");
        description = tier.content;
        image = tier.tagValue("image") ?? "https://c10.patreonusercontent.com/4/patreon-media/p/reward/5573765/9d074162251943e5ab33aab20473401b/eyJ3Ijo0MDB9/1.jpg?token-time=2145916800&token-hash=cv0bruLHhMqG8H2k18NhN0rjdHmfeOTTifNxVoRYRNw%3D";
        amounts = tier.getMatchingTags("amount").reduce((acc, tag) => {
            acc[tag[3]] = tag[1];
            return acc;
        }, {} as Record<string, string>);
    }

    const dispatch = createEventDispatcher();
    const defaultImage = "https://c10.patreonusercontent.com/4/patreon-media/p/reward/5573765/9d074162251943e5ab33aab20473401b/eyJ3Ijo0MDB9/1.jpg?token-time=2145916800&token-hash=cv0bruLHhMqG8H2k18NhN0rjdHmfeOTTifNxVoRYRNw%3D";

    let editName = false;
    let editAmount = false;
    let editDescription = false;
</script>

<div class="card card-compact full-image !rounded-3xl">
    <figure class="relative group">
        <img src={image} alt="Tier Image" />
        <button class="z-50 btn btn-circle btn-black btn-sm absolute top-2 right-2 opacity-0 group-hover:opacity-100 transition-all duration-100" on:click={() => {image = prompt("Enter new URL") || defaultImage}}>
            <Pencil color="white" class="" />
        </button>
    </figure>
    <div class="card-body self-stretch p-4 bg-neutral-100 justify-between items-start flex-col min-w-[250px] min-h-[300px] gap-4 inline-flex w-full h-full">
        <div class="flex flex-col gap-4 w-full">
            <div class="flex-col justify-start items-start gap-2 flex w-full">
                <div class="text-black text-2xl font-medium w-full items-start">
                    {#if !editName}
                        <button class="flex group flex-row justify-between items-center w-full" on:click={() => editName = true}>
                            {name}
                            <Pencil color="black" class="text-lg opacity-0 group-hover:opacity-100 transition-all duration-100" />
                        </button>
                    {:else}
                        <Input
                            bind:value={name}
                            class="w-64 !bg-transparent text-2xl"
                            on:blur={() => editName = false }
                            on:keyup={(k) => {
                                if (k.key === "Enter") {
                                    editName = false;
                                }
                            }}
                        />
                    {/if}
                </div>
                {#if !editAmount}
                    {#each terms as term}
                        <button class="flex group flex-row justify-between items-center w-full" on:click={() => editAmount = true}>
                            <div class="text-center text-black text-base font-medium">${amounts[term]}
                            /{term}</div>
                            <Pencil color="black" class="text-lg opacity-0 group-hover:opacity-100 transition-all duration-100" />
                        </button>
                    {/each}
                {:else}
                    {#each terms as term}
                        <div class="flex flex-row justify-between items-center w-full">
                            <div class="text-center text-black text-[15px] font-medium flex flex-row gap-4 items-center">
                                <Input
                                    bind:value={amounts[term]}
                                    class="w-64 !bg-transparent"
                                    on:keyup={(k) => {
                                        if (k.key === "Enter") {
                                            editAmount = false;
                                        }
                                    }}
                                />/{term}
                            </div>
                        </div>
                    {/each}
                {/if}
            </div>
            <div class="flex-col justify-start items-start gap-4 flex w-full">
                {#if !editDescription}
                    <button class="flex group flex-row justify-between items-center w-full" on:click={() => editDescription = true}>
                        <div class="text-black text-[15px] font-light text-left whitespace-pre-line">
                            {description}
                        </div>
                        <Pencil color="black" class="text-lg opacity-0 group-hover:opacity-100 transition-all duration-100" />
                    </button>
                {:else}
                    <Textarea
                        bind:value={description}
                        on:blur={() => editDescription = false }
                        class="w-full !bg-transparent border border-neutral-800 rounded-xl rounded-t-none resize-none text-black" />
                {/if}

            </div>
        </div>

        {#if tierModified}
            <button class="button button-primary w-full self-end" on:click={() => dispatch('save')}>
                Save
            </button>
        {:else}
            <button class="button button-primary w-full self-end" on:click={() => dispatch('remove')}>
                {#if tier?.sig}
                    Delete
                {:else}
                    Remove
                {/if}
            </button>
        {/if}
    </div>
</div>