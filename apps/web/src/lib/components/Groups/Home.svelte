<script lang="ts">
	import HorizontalList from '$components/PageElements/HorizontalList';
	import { NDKArticle, NDKKind, NDKSimpleGroup, NDKSimpleGroupMetadata, NDKSubscriptionTier } from "@nostr-dev-kit/ndk";
	import { getContext } from "svelte";
	import { Readable } from "svelte/store";
    import * as Card from "$components/Card";
    import * as Groups from "$components/Groups";
	import { layout } from '$stores/layout';

    const group = getContext('group') as NDKSimpleGroup;
    const metadata = getContext("groupMetadata") as Readable<NDKSimpleGroupMetadata>;
    const isMember = getContext("isMember") as Readable<boolean>;
    
    $layout.footerInMain = true;
    $: if ($isMember) {
        $layout.footer = {
            component: Groups.Footers.Home,
            props: { group }
        }
    }

    const tiers = getContext("groupTiers") as Readable<NDKSubscriptionTier[]>;
    const articles = getContext("groupArticles") as Readable<NDKArticle[]>;
</script>


isMember = {$isMember}
<HorizontalList class="py-[var(--section-vertical-padding)]" title="Articles" items={$articles} let:item>
    <Card.Article article={item} />
</HorizontalList>
