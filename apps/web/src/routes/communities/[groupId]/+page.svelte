<script lang="ts">
    import * as Tiers from "$components/Tiers";
	import Tier from "$components/Tier.svelte";
    import { ndk } from "$stores/ndk";
	import { NDKKind, NDKSimpleGroup, NDKSubscriptionTier } from "@nostr-dev-kit/ndk";
	import { getContext } from "svelte";
	import { Readable } from "svelte/store";

    const group = getContext("group") as NDKSimpleGroup;
    const tiers = getContext("groupTiers") as Readable<NDKSubscriptionTier[]>;
</script>

{#each $tiers as tier}
    <Tier tier={tier} selected={true} currency="usd" term="monthly" />
{/each}