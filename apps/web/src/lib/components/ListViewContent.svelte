<script lang="ts">
	import { RelativeTime, Textarea, ndk, user } from '@kind0/ui-common';
	import { NDKArticle, type NDKList } from "@nostr-dev-kit/ndk";
	import AvatarWithName from '$components/User/AvatarWithName.svelte';
	import Article from '$components/List/Article.svelte';
	import { page } from '$app/stores';
	import { EventContent } from '@nostr-dev-kit/ndk-svelte-components';
	import EventActionButtons from './buttons/EventActionButtons.svelte';

    export let list: NDKList;
    export let urlPrefix: string;

    const listImage = list.tagValue("image");

    const filters = list.filterForItems();
    const items = $ndk.storeSubscribe(filters);

    let selectedItemId: string | undefined = undefined;

    $: selectedItemId = $page.params.subId;

    let editDescription: string | null = null;

    function keyDown(e: KeyboardEvent) {
        if (e.key === "Enter" && e.ctrlKey) {
            saveDescription();
        }
    }

    async function saveDescription() {
        list.content = editDescription??"";
        list.id = "";
        list.sig = "";
        await list.publish();
        editDescription = null;
    }
</script>

<div class="px-4 w-full flex flex-col gap-2">
    {#if listImage}
        <img src={listImage} alt={list.title} class="w-full h-auto object-cover rounded-2xl" />
    {/if}

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
                        Save
                    </button>
                </div>
            {/if}
        {:else if list.content.length > 0}
            <div class="items-start text-lg">
                {list.content}
            </div>
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