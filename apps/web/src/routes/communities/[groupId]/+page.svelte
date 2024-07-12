<script lang="ts">
	import HorizontalList from '$components/PageElements/HorizontalList';
	import { NDKArticle, NDKKind, NDKSimpleGroup, NDKSubscriptionTier } from "@nostr-dev-kit/ndk";
	import { getContext } from "svelte";
	import { Readable } from "svelte/store";
    import * as Card from "$components/Card";

    const group = getContext("group") as NDKSimpleGroup;
    const tiers = getContext("groupTiers") as Readable<NDKSubscriptionTier[]>;
    const articles = getContext("groupArticles") as Readable<NDKArticle[]>;
</script>

<HorizontalList class="py-[var(--section-vertical-padding)]" title="Articles" items={$articles} let:item>
    <Card.Article article={item} />
</HorizontalList>
