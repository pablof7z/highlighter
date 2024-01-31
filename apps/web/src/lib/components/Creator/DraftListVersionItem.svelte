<script lang="ts">
	import type { DraftCheckpoint } from "$stores/drafts";
	import { newToasterMessage } from "@kind0/ui-common";
	import DraftItem from "./DraftItem.svelte";
	import { countWords } from "$utils/article";

    export let draft: DraftItem;
    export let checkpoint: DraftCheckpoint;

    let wordCount: number;
    let url: string;

    url = `/drafts/${draft.id}&checkpoint=` + checkpoint.time;

</script>

<li>
    <a href={url} class="whitespace-nowrap">
        {(new Date(checkpoint.time)).toLocaleString()}
        {#if wordCount > 0}
            <div class="badge badge-ghost badge-xs justify-self-start">
                {wordCount} words
            </div>
        {/if}
        {#if checkpoint.manuallySaved}
            <span class="badge badge-success">Manually saved</span>
        {/if}
    </a>
</li>