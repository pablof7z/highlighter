<script lang="ts">
	import PageTitle from "$components/PageElements/PageTitle.svelte";
	import { ndk } from "$stores/ndk";
	import { NDKKind, NDKSimpleGroup } from "@nostr-dev-kit/ndk";
	import { onDestroy } from "svelte";

    export let group: NDKSimpleGroup;
    export let href: string;

    const chat = $ndk.storeSubscribe({
        kinds: [NDKKind.GroupChat], "#h": [group.groupId]
    }, { groupable: true, subId: 'group-content' });

    onDestroy(() => {
        chat.unsubscribe();
    })
</script>

<PageTitle title={group.name} />