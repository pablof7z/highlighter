<script lang="ts">
	import ModalShell from "$components/ModalShell.svelte";
	import Checkbox from "$components/Forms/Checkbox.svelte";
	import ScrollArea from "$components/ui/scroll-area/scroll-area.svelte";
	import { userArticles, userPinList, userVideos } from "$stores/user-view";
	import { NavigationOption } from "../../app";
	import { NDKKind, NDKList, NostrEvent } from "@nostr-dev-kit/ndk";
	import { ndk } from "$stores/ndk";
	import { closeModal } from "$utils/modal";

    async function save() {
        const pinnedItems = Object.keys(pinned).filter(key => pinned[key]);
        const pinnedEvent = $userPinList ?? new NDKList($ndk, { kind: NDKKind.PinList } as NostrEvent);
        const tags = pinnedEvent.items;

        // remove was is on the list unchecked
        for (let i = tags.length - 1; i >= 0; i--) {
            if (!pinned[tags[i][1]]) {
                tags.splice(i, 1);
            }
        }

        // add what's is pinned
        for (const key of pinnedItems) {
            if (!tags.find(tag => tag[1] === key)) {
                tags.unshift(["a", key]);
            }
        }

        pinnedEvent.tags = tags;
        await pinnedEvent.sign()
        pinnedEvent.publishReplaceable();
        closeModal();
    }

    let actionButtons: NavigationOption[] = [
        { name: "Save Pin", fn: save },
    ]

    let pinned: Record<string, boolean> = {};

    $userPinList?.items.forEach(([_, tagId]) => {
        pinned[tagId] = true;
    });
</script>

<ModalShell
    title="Pin Content"
    {actionButtons}
>
    <ScrollArea>
        {#if $userArticles}
            <h3>Articles</h3>

            <ul>
                {#each $userArticles as article}
                    <li>
                        <Checkbox bind:value={pinned[article.tagId()]}>
                            {article.title}
                        </Checkbox>
                    </li>
                {/each}
            </ul>
        {/if}

        {#if $userVideos}
            <h3>Videos</h3>

            <ul>
                {#each $userVideos as article}
                    <li>
                        <label class="text-muted-foreground text-sm flex flex-row items-center gap-2">
                            <Checkbox />
                            {article.title}

                        </label>
                    </li>
                {/each}
            </ul>
        {/if}
    </ScrollArea>
</ModalShell>

<style lang="postcss">
    h3 {
        @apply text-lg font-bold;
    }
</style>