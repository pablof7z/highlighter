<script lang="ts">
	import Checkbox from "$components/Forms/Checkbox.svelte";
	import BlankState from "$components/PageElements/BlankState.svelte";
    import ScrollArea from "$components/ui/scroll-area/scroll-area.svelte";
	import { userArticleCurations } from "$stores/session";
    import { NDKArticle } from "@nostr-dev-kit/ndk";
	import { createEventDispatcher } from "svelte";

    export let article: NDKArticle;
    export let forceSave = false;

    const dispatch = createEventDispatcher();

    $: if (forceSave) { forceSave = false; save(); }

    async function save() {
        const changedItems = Object.keys(selected).filter(k => selected[k] !== originalSelection[k]);
        console.log('changed items', changedItems);

        for (const curationId of changedItems) {
            const curation = $userArticleCurations.get(curationId);
            if (curation) {
                if (selected[curationId]) {
                    curation.addItem(article);
                    console.log('add item', curation.title);
                } else {
                    curation.removeItemByValue(article.tagId());
                    console.log('remove item', curation.title);
                }

                console.log('curation items', curation.items);

                curation.publishReplaceable();
            }
        }

        dispatch("close");
    }

    const originalSelection: Record<string, boolean> = {};
    const selected: Record<string, boolean> = {};

    const articleId = article.tagId();

    $: for (const [curationId, curation] of $userArticleCurations.entries()) {
        if (selected[curationId] === undefined) {
            selected[curationId] = !!curation.has(articleId);
            originalSelection[curationId] = selected[curationId];
        }
    }
</script>

<ScrollArea orientation="vertical">
    <ul class="h-max bg-background/50 rounded border border-border overflow-clip gap-0 divide-y divide-border">
        {#if $userArticleCurations.size === 0}
            <BlankState cta="Create Curation">
                You don't have any curations. Create one to add this article to.
            </BlankState>
        {/if}

        {#each $userArticleCurations.values() as curation (curation.id)}
            <li class="m-0 p-0">
                <Checkbox
                    class="w-full hover:bg-secondary p-4 !m-0"
                    icon={curation.image}
                    bind:value={selected[curation.tagId()]}
                    type="switch"
                >
                    {curation.title}

                    <div class="text-muted-foreground text-sm" slot="description">
                        {curation.description??""}
                    </div>
                </Checkbox>
            </li>
        {/each}
    </ul>
</ScrollArea>