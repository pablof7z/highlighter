<script lang="ts">
	import { Eye } from 'phosphor-svelte';
	import { Check } from 'phosphor-svelte';
	import { getEventUrl } from '$utils/url';
	import {Button} from "$components/ui/button";
	import { Plus } from 'phosphor-svelte';
	import { BookmarkSimple, Bookmark } from 'phosphor-svelte';
    import { userArticleCurations, userHighlightCurations } from '$stores/session.js';
	import { ndk } from '$stores/ndk.js';
	import ButtonWithCount from '$components/buttons/ButtonWithCount.svelte';
	import { NDKEvent, NDKKind, NDKList } from '@nostr-dev-kit/ndk';
	import { onDestroy } from 'svelte';
	import { derived, Writable } from 'svelte/store';
	import ReplyAvatars from '../../Feed/ReplyAvatars.svelte';
    import * as Tooltip from "$lib/components/ui/tooltip";
    import * as HoverCard from "$lib/components/ui/hover-card";
	import { saveForLater } from '$actions/Events/save-for-later';
	import { getCurationKind } from '$utils/event';
	import { openModal } from '$utils/modal';
    import CreateCollectionModal from "$modals/Collection/Create.svelte"; 
	import { Input } from '$components/ui/input';
	import Separator from '$components/ui/separator/separator.svelte';

    export let event: NDKEvent;
    export let authorUrl: string | undefined = undefined;

    const curationKind = getCurationKind(event);

    const bookmarks = $ndk.storeSubscribe([
        { kinds: [curationKind], ...event.filter() },
    ])

    let showSaveForLater = true;
    let userCurations: Writable<Map<string, NDKList>>;
    switch (event.kind) {
        case NDKKind.Article:
            userCurations = userArticleCurations;
            break;
        case NDKKind.Highlight:
            userCurations = userHighlightCurations;
            showSaveForLater = false;
            break;
    }

    onDestroy(() => {
        bookmarks.unsubscribe();
    });

    const users = derived(bookmarks, ($bookmarks) => $bookmarks.map((bookmark) => bookmark.pubkey));

    const selectedCurations = $userCurations ? derived(userCurations!, ($userCurations) => {
        const selectedCurations: Record<string, boolean> = {};

        for (const curation of $userCurations.values()) {
            selectedCurations[curation.id] = curation.has(event.tagId());
        }

        return selectedCurations;
    }) : undefined;

    function addToCuration(curation: NDKList) {
        return () => {
            if (curation.has(event.tagId())) {
                curation.removeItemByValue(event.tagId());
                console.log('remove curation')
            } else {
                curation.addItem(event);
                console.log('add curation')
            }
        }
    }

    function createCollection() {
        const list = new NDKList($ndk);
        list.kind = curationKind;
        list.title = collectionName;
        list.addItem(event);
        list.publish();
    }

    let showAdd = false;
    let collectionName = '';
</script>

<div
    class="flex flex-row items-center gap-2"
>
    <HoverCard.Root openDelay={0} closeDelay={250}>
        <HoverCard.Trigger>
            <ButtonWithCount
                count={$bookmarks.length}
                class="gap-3 hover:bg-red-500/20 group rounded-full text-muted-foreground"
                on:click
            >
                <BookmarkSimple size={20} weight="bold" class="transition-all duration-100 group-hover:text-red-500" />
                <svelte:fragment slot="after">
                    <ReplyAvatars users={$users} size="xs" />
                </svelte:fragment>
            </ButtonWithCount>

        </HoverCard.Trigger>

        <HoverCard.Content class="p-0 w-fit flex flex-col items-stretch">
            {#if showSaveForLater}
                <Button variant="ghost" class="items-start justify-start" on:click={() => saveForLater(event)}>
                    <Bookmark size={20} weight="bold" class="mr-3" />
                    <span class="text-muted-foreground">Save for Later</span>
                </Button>
            {/if}

            {#if $userCurations}
                {#each $userCurations.values() as curation (curation.id)}
                    <Button variant="ghost" class="items-start justify-start rounded-none" on:click={addToCuration(curation)}>
                        <Check size={20} weight="bold" class="
                            mr-3
                            {!$selectedCurations?.[curation.id] ? 'opacity-0' : 'text-accent'}
                        " />
                        <span class="text-muted-foreground">
                            {curation.title}
                        </span>
                    </Button>
                {/each}
            {/if}

            <Button variant="ghost" class="items-start justify-start rounded-none" on:click={(e) => {
                showAdd = true;
                e.preventDefault();
                e.stopPropagation();
            }}>
                <Plus size={20} weight="bold" class="mr-3" />
                {#if showAdd}
                    <input
                        class="border-0 !outline-none bg-transparent font-normal w-32"
                        autofocus
                        placeholder="Collection Name"
                        on:blur={() => showAdd = false}
                        on:keydown={(e) => {
                            if (e.key === 'Enter') {
                                createCollection();
                            }
                        }}
                        bind:value={collectionName}
                    />
                {:else}
                    <span class="text-muted-foreground">New Collection</span>
                {/if}
            </Button>

            {#if $bookmarks.length > 0}
                <Separator />
            
                <Button variant="ghost" class="items-start justify-start w-full" href={getEventUrl(event, authorUrl, 'shares')}>
                    <Eye size={20} weight="bold" class="mr-3" />
                    <span class="text-muted-foreground mr-6 grow">Curations</span>
                    <ReplyAvatars users={$users} size="xs" />
                </Button>
            {/if}
        </HoverCard.Content>
    </HoverCard.Root>
</div>