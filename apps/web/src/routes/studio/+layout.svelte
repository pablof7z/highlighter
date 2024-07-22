 <script lang="ts">
	import { page } from "$app/stores";
    import * as Studio from "$components/Studio";
	import { DraftCheckpoint, DraftItem } from "$stores/drafts";
	import { layout } from "$stores/layout";
	import { getDraft } from "./drafts";
    import { Thread } from '$utils/thread';
	import { Writable } from "svelte/store";

    const draftId = $page.url.searchParams.get("draft") || undefined;
    const checkpointId = $page.url.searchParams.get("checkpoint") || undefined;
    let draft: DraftItem | undefined = undefined;
    let checkpoint: DraftCheckpoint | undefined = undefined;

    if (draftId) {
        const res = getDraft(draftId, checkpointId);
        if (res) {
            draft = res.draft;
        }
    }

    $layout.fullWidth = false;
    $layout.title = "Studio";
    $layout.navigation = false;
    $layout.sidebar = false;

    let publishInGroups: Writable<Map<string, string[]>>;
    let groupsSet = false;
    $: if ($publishInGroups && !groupsSet) {
        groupsSet = true;
        const groupId = $page.url.searchParams.get("group");
        const relays = $page.url.searchParams.getAll("relay");
        if (groupId) {
            $publishInGroups.set(groupId, relays);
        }
    }

    
</script>

<Studio.Root
    let:groups
    bind:publishInGroups
    let:mode
    let:publishAt
    let:type
    let:event
>
    <Studio.Shell
        {groups}
        {event}
        {draft}
        {mode}
        {publishInGroups}
        {publishAt}
        {type}
    >
        <slot />
    </Studio.Shell>
</Studio.Root>