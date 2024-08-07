<script lang="ts">
	import HorizontalList from '$components/PageElements/HorizontalList';
	import { NDKArticle, NDKKind, NDKSimpleGroup, NDKSimpleGroupMemberList, NDKSimpleGroupMetadata, NDKSubscriptionTier } from "@nostr-dev-kit/ndk";
	import { getContext } from "svelte";
	import { Readable } from "svelte/store";
    import * as Card from "$components/Card";
    import * as Groups from "$components/Groups";
	import { layout } from '$stores/layout';

    export let group = getContext('group') as NDKSimpleGroup;
    export let metadata = getContext("groupMetadata") as Readable<NDKSimpleGroupMetadata>;
    export let members = getContext("groupMembers") as Readable<NDKSimpleGroupMemberList | undefined>;
    export let isMember = getContext("isMember") as Readable<boolean>;
    
    $layout.footerInMain = true;
    $layout.title = $metadata.name;
    $layout.fullWidth = false;
    $: if ($isMember) {
        $layout.footer = {
            component: Groups.Footers.Home,
            props: { group, metadata }
        }
    }
</script>

<Groups.Header
    metadata={$metadata}
    members={$members}
    isMember={$isMember}

/>
