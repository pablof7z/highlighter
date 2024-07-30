<script lang="ts">
    import * as DropdownMenu from "$components/ui/dropdown-menu";
	import currentUser from "$stores/currentUser";
	import { ndk } from "$stores/ndk";
	import { NDKEvent, NDKKind, NDKList } from "@nostr-dev-kit/ndk";
	import { BookmarkSimple } from "phosphor-svelte";
    
    export let event: NDKEvent;
    export let open: boolean;
    
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

    function clicked(e: Event) {
    }
</script>

<DropdownMenu.Item on:click={clicked}>
    {#if $$slots.default}
        <slot />
    {:else}
        <BookmarkSimple size={24} />
        Save for later
    {/if}
</DropdownMenu.Item>