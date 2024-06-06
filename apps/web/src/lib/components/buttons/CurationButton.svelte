<script lang="ts">
	import { type Writable } from 'svelte/store';
	import { userArticleCurations, userVideoCurations } from "$stores/session";
	import { NDKEvent, NDKList, NDKKind } from "@nostr-dev-kit/ndk";
	import { BookmarkSimple, Heart, Lock, PaperPlaneTilt, Plus, RowsPlusBottom } from "phosphor-svelte";
	import { curationHasEvent } from '$utils/curations';

    export let event: NDKEvent;

    let listStore: Writable<Map<string, NDKList>>;
    let listKind: number;

    let bookmarked = false;

    const tagId = event.tagId();

    $: for (const curation of $listStore.values()) {
        if (curationHasEvent(curation)) {
            bookmarked = true;
            break;
        }
    }
</script>

<div
    class="dropdown"
    class:dropdown-open={showCreate}
>
    <!-- svelte-ignore a11y-no-noninteractive-tabindex -->
    <!-- svelte-ignore a11y-label-has-associated-control -->
    <label tabindex="0" class="cursor-pointer">
        <RowsPlusBottom
            class="w-7 h-7
                {bookmarked ? 'text-accent' : ''}
            " weight={bookmarked ? "fill" : "regular"}
        />
    </label>
    <!-- svelte-ignore a11y-no-noninteractive-tabindex -->
    <ul tabindex="0" class="dropdown-content z-[1] menu p-2 shadow rounded overflow-x-clip truncate flex-nowrap">
    </ul>
</div>

<style lang="postcss">
    button.active {
        @apply border-l-4 border-accent rounded-l-none font-semibold;
    }
</style>
