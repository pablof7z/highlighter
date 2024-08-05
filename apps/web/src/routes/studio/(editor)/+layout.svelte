 <script lang="ts">
	import { page } from "$app/stores";
    import * as Studio from "$components/Studio";
	import { layout } from "$stores/layout";
	import { writable, Writable } from "svelte/store";

    const draftId = $page.url.searchParams.get("draft") || undefined;
    const checkpointId = $page.url.searchParams.get("checkpoint") || undefined;

    const eventId = $page.url.searchParams.get("eventId") || undefined;

    $layout.fullWidth = false;
    $layout.title = "Studio";
    $layout.navigation = false;
    $layout.sidebar = false;

    let publishInGroups: Writable<Map<string, string[]>> = writable(new Map());
    let groupsSet = false;
    $: if ($publishInGroups && !groupsSet) {
        groupsSet = true;
        const groupId = $page.url.searchParams.get("group");
        const relays = $page.url.searchParams.getAll("relay");
        if (groupId) {
            publishInGroups.set(
                new Map([[groupId, relays]])
            );
        }
    }
</script>

<Studio.Root
    {draftId} {checkpointId}
    {eventId}
    bind:publishInGroups
    let:mode
    let:preview
    let:groupsList
    let:publishScope
    let:publishAt
    let:withPreview
    let:publishInTiers
    let:type
    let:event
    let:thread
    let:draft
>
    <Studio.Shell
        {event}
        {preview}
        {withPreview}
        {groupsList}
        {publishScope}
        {thread}
        {mode}
        {publishInGroups}
        {publishInTiers}
        {publishAt}
        {type}
        {draft}
    >
        <slot />
    </Studio.Shell>
</Studio.Root>