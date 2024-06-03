<script lang="ts">
	import { NDKArticle, type NDKList } from "@nostr-dev-kit/ndk";
	import AvatarWithName from '$components/User/AvatarWithName.svelte';
	import Article from '$components/List/Article.svelte';
	import { page } from '$app/stores';
	import { onDestroy } from 'svelte';

    export let list: NDKList;
    export let urlPrefix: string;

    const listImage = list.tagValue("image");

    const filters = list.filterForItems();
    const items = $ndk.storeSubscribe(filters);

    onDestroy(() => {
        items.unsubscribe();
    });

    let selectedItemId: string | undefined = undefined;
    let saving = false;

    $: selectedItemId = $page.params.subId;

    let editDescription: string | null = null;

    function keyDown(e: KeyboardEvent) {
        if (e.key === "Enter" && e.ctrlKey) {
            saveDescription();
        }
    }

    async function saveDescription() {
        saving = true;
        list.content = editDescription??"";
        list.id = "";
        list.sig = "";
        try {
            await list.publish();
        } finally {
            saving = false;
        }
        editDescription = null;
    }
</script>

<div class="sm:px-4 w-full flex flex-col gap-2">
    {#if listImage}
        <div class="-mb-10 relative -z-1">
            <div class="absolute w-full bottom-0 bg-gradient-to-b from-transparent to-base-100 h-32"></div>
            <img src={listImage} alt={list.title} class="w-full h-auto object-cover max-h-[20dvh] min-h-[5rem]" />
        </div>
    {/if}

    <h1 class="max-sm:px-4 text-white font-semibold z-1 relative">
        {list.title}
    </h1>

    <div class="flex flex-row items-center w-full justify-between">
        <AvatarWithName
            user={list.author}
            avatarSize="small"
        />

        <RelativeTime event={list} class="text-neutral-500 text-sm" />
    </div>

    <div class="text-left font-light">
        {#if list.pubkey === $user?.pubkey}
            {#if editDescription === null}
                <button
                    class="cursor-pointer w-full hover:bg-base-300"
                    on:click={() => editDescription = list.content??""}>
                    <div class="items-start text-left text-lg">
                        {#if list.content.length > 0}
                            {list.content}
                        {:else}
                            <p>Add a description to {list.title}</p>
                        {/if}
                    </div>
                </button>
            {:else}
                <Textarea
                    bind:value={editDescription}
                    on:keydown={keyDown}
                    class="w-full items-start"
                />
                <div class="flex flex-row justify-end">
                    <button class="button" on:click={saveDescription}>
                        {#if saving}
                            Saving...
                        {:else}
                            Save
                        {/if}
                    </button>
                </div>
            {/if}
        {:else if list.content.length > 0}
            <button class="items-start text-lg" on:click={() => editDescription = list.content??""}>
                {list.content}
            </button>
        {/if}
    </div>
</div>

<div class="h-full overflow-y-auto flex flex-col mt-5   border-t border-base-300">
    {#each $items as item (item.id)}
        <Article
            article={NDKArticle.from(item)}
            class="
                p-4
                {selectedItemId === item.tagValue("d") ? "list-item--active" : undefined}
            "
            href={`${urlPrefix}/${item.tagValue("d")}`}
        />
    {/each}
</div>

<style lang="postcss">
    .content {
        @apply mb-4 w-full;
    }
</style>