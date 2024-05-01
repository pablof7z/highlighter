<script lang="ts">
	import { toggleBookmarkedEvent } from "$lib/events/bookmark";
	import { userGenericCuration } from "$stores/session";
	import { ndk, newToasterMessage } from "@kind0/ui-common";
	import { NDKEvent, NDKList, type NostrEvent } from "@nostr-dev-kit/ndk";
    import BookmarksSimple from "phosphor-svelte/lib/BookmarkSimple";
	import { quintInOut } from "svelte/easing";
	import { crossfade, draw, scale } from "svelte/transition";

    export let event: NDKEvent;

    const eventReferenceTag = event.tagId()

    let saved = false;
    let prevSaved: boolean = undefined;

    $: saved = $userGenericCuration.items.some(tag => tag[1] === eventReferenceTag) ?? false;
    $: if (saved !== prevSaved && prevSaved !== undefined && button) {
        prevSaved = saved;
        button.classList.add("!ring-8");
        button.classList.add("scale-150");
        setTimeout(() => {
            button.classList.remove("!ring-8");
            button.classList.remove("scale-150");
        }, 1000);
    }

    let button: HTMLElement;

    async function save(ev: MouseEvent) {
        ev.stopPropagation();


        const e = new NDKList($ndk, $userGenericCuration.rawEvent());

        if (saved) {
            e.tags = e.tags?.filter(tag => tag[1] !== eventReferenceTag);
        } else {
            e.addItem(event.tagReference(), undefined, false, "top");
        }

        try {
            $userGenericCuration = await toggleBookmarkedEvent(event, $userGenericCuration);
        } catch (e: any) {
            newToasterMessage(e.relayErrors ?? e.message, "error")
        }
    }
</script>

<div class="tooltip {$$props.class??""}"  data-tip="Bookmark">
    <button
        class="rounded-full ring-0 ring-accent2/30 transition-all duration-1000"
        class:text-accent2={saved}
        on:click|stopImmediatePropagation|preventDefault|capture={save}
        bind:this={button}
    >
        <BookmarksSimple
            class={$$props.class??"w-7 h-7"}
            weight={saved ? "fill" : "regular"}
        />
    </button>
</div>