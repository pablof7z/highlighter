<script lang="ts">
	import type { DraftCheckpoint, DraftItem } from "$stores/drafts";
	import { Badge } from "$components/ui/badge";

    export let item: DraftItem;
    export let checkpoint: DraftCheckpoint;
    export let type: string;

    let url: string;

    url = `/studio/${type}?draft=${item.id}&checkpoint=` + checkpoint.time;

</script>

<a data-sveltekit-reload href={url} class="whitespace-nowrap flex flex-col gap-2">
    <div class="flex flex-row gap-4">
        {(new Date(checkpoint.time)).toLocaleString()}
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