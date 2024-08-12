<script lang="ts">
	import { page } from "$app/stores";
    import * as Studio from "$components/Studio";
	import { layout } from "$stores/layout";

    const draftId = $page.url.searchParams.get("draft") || undefined;
    const checkpointId = $page.url.searchParams.get("checkpoint") || undefined;

    const eventId = $page.url.searchParams.get("eventId") || undefined;

    $layout.fullWidth = false;
    $layout.title = "Studio";
    $layout.navigation = false;
    $layout.sidebar = false;

    let type: Studio.Type = $page.params.type as Studio.Type;

    let groupsSet = false;
    // $: if ($publishInGroups && !groupsSet) {
    //     groupsSet = true;
    //     const groupId = $page.url.searchParams.get("group");
    //     const relays = $page.url.searchParams.getAll("relay");
    //     if (groupId) {
    //         publishInGroups.set(
    //             new Map([[groupId, relays]])
    //         );
    //     }
    // }
</script>

<Studio.Root
    {draftId} {checkpointId}
    {eventId}
    {type}
    let:state
    let:actions
>
    <Studio.Shell
        {state}
        {actions}
    >
        <slot />
    </Studio.Shell>
</Studio.Root>