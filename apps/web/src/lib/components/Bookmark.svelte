<script lang="ts">
	import { userGenericCuration } from "$stores/session";
	import { ndk, newToasterMessage } from "@kind0/ui-common";
	import { NDKEvent, NDKList, type NostrEvent } from "@nostr-dev-kit/ndk";
    import BookmarksSimple from "phosphor-svelte/lib/BookmarkSimple";

    export let event: NDKEvent;

    const eventReferenceTag = event.tagId()

    let saved = false;

    $: saved = $userGenericCuration.items.some(tag => tag[1] === eventReferenceTag) ?? false;

    async function save(ev: MouseEvent) {
        ev.stopPropagation();

        const e = new NDKList($ndk, $userGenericCuration.rawEvent());

        if (saved) {
            e.tags = e.tags?.filter(tag => tag[1] !== eventReferenceTag);
        } else {
            e.addItem(event.tagReference(), undefined, false, "top");
        }

        try {
            await e.publish();
            $userGenericCuration = e;
        } catch (e: any) {
            newToasterMessage(e.relayErrors ?? e.message, "error")
        }
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