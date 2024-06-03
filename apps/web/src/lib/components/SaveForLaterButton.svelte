<script lang="ts">
	import currentUser from "$stores/currentUser";
	import { ndk } from "$stores/ndk";
	import { NDKKind, type NDKEvent, NDKList, type NostrEvent } from "@nostr-dev-kit/ndk";
    import BookmarksSimple from "phosphor-svelte/lib/BookmarkSimple";
	import { onDestroy } from "svelte";

    export let event: NDKEvent;

    const eventReferenceTag = event.tagId()

    let listTitle: string;
    let listKind: number | undefined;

    if (event.kind === NDKKind.Article) {
        listKind = NDKKind.ArticleCurationSet;
        listTitle = "Read Later";
    } else if (event.kind === NDKKind.HorizontalVideo) {
        listKind = NDKKind.VideoCurationSet;
        listTitle = "Watch Later";
    } else {
        listKind = NDKKind.BookmarkSet;
        listTitle = "Saved for Later";
    }

    const lists = $ndk.storeSubscribe({
        kinds: [listKind],
        "#d": ["saved"],
        authors: [$currentUser.pubkey]
    }, {
        subId: 'save-for-later-button',
        groupable: true,
        groupableDelay: 500
    }, NDKList);

    onDestroy(() => { lists?.unsubscribe(); })

    let saved = false;

    let list: NDKList | undefined;

    $: list = $lists[0];

    $: if (list) saved = list.items.some(tag => tag[1] === eventReferenceTag) ?? false;

    async function save(e: MouseEvent) {
        e.stopPropagation();

        if (!list) {
            list = new NDKList($ndk, { kind: listKind } as NostrEvent);
            list.dTag = "saved";
        }

        list.title = listTitle;

        if (saved) {
            list.tags = list.tags?.filter(tag => tag[1] !== eventReferenceTag);
        } else {
            list.addItem(event.tagReference());
        }

        console.log("event", list.rawEvent())
        list.sig = "";
        list.id = "";
        await list.publish();
    }
</script>

{#if listKind}
    <div class="tooltip tooltip-left {$$props.class??""}"  data-tip={`Add to "${listTitle}"`}>
        <button
            class:text-accent={saved}
            on:click|stopImmediatePropagation|preventDefault|capture={save}
        >
            <BookmarksSimple
                class="w-7 h-7"
                weight={saved ? "fill" : "regular"}
            />
        </button>
    </div>
{/if}