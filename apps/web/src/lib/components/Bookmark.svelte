<script lang="ts">
	import { userGenericCuration } from "$stores/session";
	import { type NDKEvent, NDKList, type NostrEvent } from "@nostr-dev-kit/ndk";
    import BookmarksSimple from "phosphor-svelte/lib/BookmarkSimple";

    export let event: NDKEvent;

    const eventReferenceTag = event.tagId()

    let saved = false;

    $: saved = $userGenericCuration.items.some(tag => tag[1] === eventReferenceTag) ?? false;

    async function save(e: MouseEvent) {
        e.stopPropagation();

        if (saved) {
            $userGenericCuration.tags = $userGenericCuration.tags?.filter(tag => tag[1] !== eventReferenceTag);
        } else {
            $userGenericCuration.addItem(event.tagReference());
        }

        $userGenericCuration.created_at = Math.floor(Date.now() / 1000);
        $userGenericCuration.sig = "";
        $userGenericCuration.id = "";
        await $userGenericCuration.publish();
    }
</script>

<div class="tooltip {$$props.class??""}"  data-tip="Bookmark">
    <button
        class:text-accent2={saved}
        on:click|stopImmediatePropagation|preventDefault|capture={save}
    >
        <BookmarksSimple
            class={$$props.class??"w-7 h-7"}
            weight={saved ? "fill" : "regular"}
        />
    </button>
</div>