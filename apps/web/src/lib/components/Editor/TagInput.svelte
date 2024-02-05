<script lang="ts">
	import { NDKSubscriptionCacheUsage, type NDKEvent } from "@nostr-dev-kit/ndk";
    import GlassyInput from "$components/Forms/GlassyInput.svelte";
	import { Textarea, ndk } from '@kind0/ui-common';
	import { onDestroy } from 'svelte';
	import { derived } from 'svelte/store';

    export let event: NDKEvent;

    const events = $ndk.storeSubscribe({ kinds: [event.kind!]}, { closeOnEose: true, cacheUsage: NDKSubscriptionCacheUsage.ONLY_CACHE });
    const tags = derived(events, $events => {
        const tags = new Map();
        for (const event of $events) {
            for (const tag of event.getMatchingTags("t")) {
                const value = tag[1];
                if (
                    value.startsWith("#") ||
                    value.length > 15
                ) continue;

                const count = tags.get(value) || 0;

                tags.set(value, count + 1);
            }
        }

        // create a sorted by count array of tags
        return Array.from(tags.entries()).sort((a, b) => b[1] - a[1]).map(t => t[0]);
    });

    onDestroy(() => {
        events.unsubscribe();
    });

    let tagString: string = event.getMatchingTags("t").map(t => t[1]).join(", ");
    let tagCount: number;
    let lastWord: string | undefined;
    $: tagCount = event.getMatchingTags("t").length;

    $: {
        let tagArray = tagString.split(",").map(t => t.trim());
        tagArray = tagArray.filter(t => t.length > 0);
        event.removeTag("t");
        for (let tag of tagArray) {
            event.tags.push(["t", tag]);
            lastWord = tag;
        }

        if (tagArray.length === 0) {
            lastWord = undefined;
        }

        // if we finish in a comma lastWord is undefined
        if (tagString.match(/,[ ]*$/i)) {
            lastWord = undefined;
        }

        event = event;
    }

    function addTag(tag: string) {
        // remove the last word
        let v = tagString.split(",").slice(0, -1).join(", ");
        if (v.length > 0) {
            v += ", ";
        }
        v += tag + ", ";
        tagString = v;
        lastWord = undefined;
    }

    let hasFocus = false;
</script>

<section class="settings">
    <div class="field">
        <div class="title">
            Tags ({tagCount})
        </div>

        <Textarea
            class="w-full !bg-white/5 rounded-box focus:!border-white/20"
            bind:value={tagString}
            on:focus={() => hasFocus = true}
            on:blur={() => hasFocus = false}
        />
        <div class="text-xs text-neutral-500">
            Separate tags with commas
        </div>
    </div>

    <div class="flex flex-row gap-1 w-full flex-wrap" class:hiddsen={!lastWord}>
        {#each $tags.filter(t => t.includes(lastWord)) as tag}
            <button class="badge bg-white/10 !p-4" on:click={() => addTag(tag)}>
                {tag}
            </button>
        {/each}
    </div>
</section>