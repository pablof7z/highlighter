<script lang="ts">
	import type { DraftCheckpoint } from "$stores/drafts";
	import { newToasterMessage } from "$stores/toaster.js";
	import DraftItem from "./DraftItem.svelte";
	import { countWords } from "$utils/article";
	import { Badge } from "$components/ui/badge";

    export let draft: DraftItem;
    export let checkpoint: DraftCheckpoint;

    let wordCount: number = checkpoint.data?.event?.content ? countWords(checkpoint.data.event.content) : 0;
    let url: string;

    url = `/drafts/${draft.id}?checkpoint=` + checkpoint.time;

</script>

<a href={url} class="whitespace-nowrap flex flex-col gap-2">
    <div class="flex flex-row gap-4">
        {(new Date(checkpoint.time)).toLocaleString()}
        {#if wordCount > 0}
            <div class="badge badge-ghost badge-xs justify-self-start">
                {wordCount} words
            </div>
        {/if}
        {#if checkpoint.manuallySaved}
            <Badge variant="accent">Manually saved</Badge>
        {/if}
    </div>
    {#if checkpoint.relay}
        <div class="text-muted-foreground text-xs">
            Saved on {checkpoint.relay}
        </div>
    {/if}
</a>