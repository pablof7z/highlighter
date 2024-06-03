<script lang="ts">
	import { type Writable } from 'svelte/store';
	import { userArticleCurations, userVideoCurations } from "$stores/session";
    import Input from "$components/Forms/Input.svelte";
    import { ndk } from "$stores/ndk.js";
	import { NDKEvent, NDKList, NDKKind, NDKSubscriptionCacheUsage } from "@nostr-dev-kit/ndk";
	import { BookmarkSimple, List, Lock, PaperPlaneTilt, Plus, PlusCircle } from "phosphor-svelte";
	import { onDestroy } from 'svelte';

    export let event: NDKEvent;
    export let urlPrefix: string;

    let listStore: Writable<Map<string, NDKList>>;
    let listKind: number;

    switch (event.kind) {
        case NDKKind.Article:
            listStore = userArticleCurations;
            listKind = NDKKind.ArticleCurationSet;
            break;
        case NDKKind.HorizontalVideo:
            listStore = userVideoCurations;
            listKind = NDKKind.VideoCurationSet;
            break;
        default:
            listKind = NDKKind.BookmarkList;
            alert(`Not supported curation button for kind ${event.kind}`)
    }

    const curations = $ndk.storeSubscribe(
        { kinds: [ listKind ], ...event.filter() },
        { groupableDelayType: "at-least", }
    );

    onDestroy(() => {
        curations.unsubscribe();
    });

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
    class="flex flex-row items-center gap-2 group {bookmarked ? 'text-white' : ''}"
>
<div
    class="dropdown dropdown-top"
    class:dropdown-open={showCreate}
    >
        <!-- svelte-ignore a11y-no-noninteractive-tabindex -->
        <!-- svelte-ignore a11y-label-has-associated-control -->
        <label tabindex="0" class="cursor-pointer" on:click|preventDefault={(e) => {
            console.log('clicked')
        }}>
            <BookmarkSimple
                class="w-7 h-7" weight={bookmarked ? "fill" : "regular"}
            />
        </label>
        <!-- svelte-ignore a11y-no-noninteractive-tabindex -->
        <ul tabindex="0" class="dropdown-content z-50 menu p-2 rounded-box overflow-x-clip truncate flex-nowrap">
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
                        class="whitespace-nowrap w-full font-normal text-accent2"
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
            {#if $curations.length > 0}
                <div class="divider my-0"></div>
                <li class="w-full">
                    <a href="{urlPrefix}/curations" class="whitespace-nowrap">
                        <List class="w-4 h-4 mr-2" />
                        View all curations containing this
                    </a>
                </li>
            {/if}
        </ul>
    </div>

    {#if $curations.length > 0}
        <div class="tooltip" data-tip="View Curations containing this item post">
            <a href="{urlPrefix}/curations" class="font-light flex flex-row items-center gap-2 text-center transition-all duration-300">
                {$curations.length}
            </a>
        </div>
    {/if}
</div>

<style lang="postcss">
    button.active {
        @apply border-l-4 border-accent2 rounded-l-none !text-white font-semibold;
    }
</style>
