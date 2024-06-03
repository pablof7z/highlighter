<script lang="ts">
	import { Plus, Lock, PaperPlaneTilt } from 'phosphor-svelte';
	import { curationHasEvent, toggleItemInCuration, createNewCuration, getStoreForCurationEvent } from "$utils/curations";
	import { NDKEvent } from "@nostr-dev-kit/ndk";
    import Input from "$components/Forms/Input.svelte";
	import { ndk } from "$stores/ndk";

    export let event: NDKEvent;

    const listStore = getStoreForCurationEvent(event);

    let showCreate = true;
    let newCurationName = "";

    function createNew() {
        // showCreate = false;
        createNewCuration($ndk, newCurationName, event);
    }
</script>

<ul class="flex flex-col items-start flex-nowrap">
    {#each $listStore.values() as curation (curation.id)}
        <li class="w-full">
            <button
                class="whitespace-nowrap w-full font-normal"
                class:active={curationHasEvent(curation, event)}
                on:click={() => toggleItemInCuration(curation, event)}
            >
                {#await curation.encryptedTags() then encryptedTags}
                    {#if encryptedTags.length > 0}
                        <Lock class="w-4 h-4 mr-2" />
                    {/if}
                {/await}
                {curation.title}
            </button>
        </li>
    {/each}
    {#if $listStore.size > 0}
        <div class="divider my-0"></div>
    {/if}
    {#if !showCreate}
        <li class="w-full p-09">
            <button
                class="whitespace-nowrap w-full font-normal text-accent flex flex-row gap-2 items-center"
                on:click|preventDefault|stopPropagation|stopImmediatePropagation={() => showCreate = true}
            >
                <Plus class="w-4 h-4 mr-2" />
                Create new curation
            </button>
        </li>
    {:else}
        <div class="join join-horizontal p-0">
            <Input
                class="!p-0 bg-transparent !border-0 font-normal join-item"
                color="black"
                placeholder="New curation"
                bind:value={newCurationName}
                autofocus={true}
                on:keydown={(e) => {
                    if (e.key === "Enter") {
                        createNew();
                    }
                }}
            />
            <button class="btn btn-ghost join-item" on:click={createNew}>
                <PaperPlaneTilt class="w-4 h-4 text-accent" />
            </button>
        </div>
    {/if}
</ul>

<style lang="postcss">
    li {
        @apply p-2 w-full hover:bg-base-300;
    }

    button {
        @apply text-left;
    }
    
    button.active {
        @apply border-l-4 border-accent rounded-l-none font-semibold pl-4;
    }
</style>
