<script lang="ts">
	import AvatarWithName from "$components/User/AvatarWithName.svelte";
	import UserProfile from "$components/User/UserProfile.svelte";
	import throttleStore from "$utils/stores/throttle";
	import { UnsubscribableStore, ZapScore, getTopZapsByAggregatedAmount } from "$utils/zaps";
	import { NDKUser } from "@nostr-dev-kit/ndk";
	import { onDestroy } from "svelte";
	import { Readable } from "svelte/store";

    export let user: NDKUser;
	export let count: number = 5;

	let topZaps: UnsubscribableStore<ZapScore[]> | undefined;
	let debouncedTopZaps: Readable<ZapScore[]> | undefined;

	getTopZapsByAggregatedAmount(user, count).then((zaps) => {
		topZaps = zaps;
		debouncedTopZaps = throttleStore<ZapScore[]>(topZaps, 1000);
	});

	onDestroy(() => {
		topZaps?.unsubscribe();
	});
</script>

{#if $debouncedTopZaps && $debouncedTopZaps.length > 0}
	<div class="flex flex-col discussion-wrapper w-full">
		<div class="discussion-item">
			<h2 class="text-foreground font-semibold text-lg">
				Top Zappers
			</h2>
			<div class="text-xs font-light">
				In the last week
			</div>
		</div>

		{#each $debouncedTopZaps as { pubkey, totalSats } (pubkey)}
			<UserProfile {pubkey} let:userProfile let:authorUrl>
				{#if userProfile}
					<a href={authorUrl} class="flex flex-row items-center justify-between w-full discussion-item gap-4 !py-2">
						<AvatarWithName {userProfile} avatarType="circle" avatarSize="small" class="truncate" />
						<div class="text-sm font-bold">{nicelyFormattedMilliSatNumber(totalSats)}</div>
					</a>
				{/if}
			</UserProfile>
		{/each}
		<!-- <SupporterList {user} /> -->
	</div>
{/if}