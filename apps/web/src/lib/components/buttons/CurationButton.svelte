<script lang="ts">
	import { type Writable } from 'svelte/store';
	import { userArticleCurations, userVideoCurations } from "$stores/session";
    import Input from "$components/Forms/Input.svelte";
    import { ndk, user } from "@kind0/ui-common";
	import { NDKSubscriptionCacheUsage, NDKEvent, NDKList, NDKKind } from "@nostr-dev-kit/ndk";
	import { BookmarkSimple, Heart, Lock, PaperPlaneTilt, Plus } from "phosphor-svelte";
	import { onDestroy, onMount } from "svelte";
	import { getDefaultRelaySet } from '$utils/ndk';

    export let event: NDKEvent;

    let listStore: Writable<Map<string, NDKList>>;
    let listKind: number;

    switch (event.kind) {
        case NDKKind.Article:
            listStore = userArticleCurations;
            listKind = NDKKind.CurationSet;
            break;
        case NDKKind.HorizontalVideo:
            listStore = userVideoCurations;
            listKind = NDKKind.CurationSet+1;
            break;
        default:
            alert(`Not supported curation button for kind ${event.kind}`)
    }

    let bookmarked = false;

    const tagId = event.tagId();

    function curationHasEvent(curation: NDKList) {
        if (curation.items.map(tag => tag[1]).includes(tagId)) {
            return true;
        }

        return false;
    }

    $: for (const curation of $listStore.values()) {
        if (curationHasEvent(curation)) {
            bookmarked = true;
            break;
        }
    }

    async function addToCuration(curation: NDKList) {
        if (curationHasEvent(curation)) {
            return;
        }

        const isEncrypted = (await curation.encryptedTags()).length > 0;

        await curation.addItem(event.tagReference(), undefined, isEncrypted);
        await curation.sign();
        await curation.publish();
    }

    async function createNewCuration() {
        const curation = new NDKList($ndk);
        curation.kind = listKind;
        curation.title = newCurationName;
        await addToCuration(curation);
    }

    let showCreate = false;
    let newCurationName = "";
</script>

<div
    class="dropdown"
    class:dropdown-open={showCreate}
>
    <!-- svelte-ignore a11y-no-noninteractive-tabindex -->
    <!-- svelte-ignore a11y-label-has-associated-control -->
    <label tabindex="0" class="cursor-pointer">
        <BookmarkSimple
            class="w-7 h-7
                {bookmarked ? 'text-accent' : 'text-white'}
            " weight={bookmarked ? "fill" : "regular"}
        />
    </label>
    <!-- svelte-ignore a11y-no-noninteractive-tabindex -->
    <ul tabindex="0" class="dropdown-content z-[1] menu p-2 shadow rounded-box overflow-x-clip truncate flex-nowrap">
        {#each $listStore.values() as curation (curation.id)}
            <li class="w-full">
                <button
                    class="whitespace-nowrap w-full font-normal"
                    class:active={curationHasEvent(curation)}
                    on:click={() => addToCuration(curation)}
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
        <li class="w-full min-w-[16rem]">
            {#if !showCreate}
                <button
                    class="whitespace-nowrap w-full font-normal text-accent"
                    on:click|preventDefault|stopPropagation|stopImmediatePropagation={() => showCreate = true}
                >
                    <Plus class="w-4 h-4 mr-2" />
                    Create new curation
                </button>
            {:else}
                <div class="join join-horizontal p-0">
                    <Input
                        class="w-52 bg-transparent !border-0 font-normal join-item"
                        color="black"
                        placeholder="Curation name"
                        bind:value={newCurationName}
                        autofocus={true}
                        on:keydown={(e) => {
                            if (e.key === "Enter") {
                                showCreate = false;
                                createNewCuration()
                            }
                        }}
                        on:blur={() => showCreate = false}
                    />
                    <button class="btn btn-ghost join-item" on:click={createNewCuration}>
                        <PaperPlaneTilt class="w-4 h-4 text-accent" />
                    </button>
                </div>
            {/if}
        </li>
    </ul>
</div>

<style lang="postcss">
    button.active {
        @apply border-l-4 border-accent rounded-l-none !text-white font-semibold;
    }
</style>
