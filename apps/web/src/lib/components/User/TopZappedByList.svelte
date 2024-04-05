<script lang="ts">
	import AvatarWithName from "$components/User/AvatarWithName.svelte";
	import UserProfile from "$components/User/UserProfile.svelte";
	import {nicelyFormattedMilliSatNumber} from "@kind0/ui-common";
	import { ndk } from "@kind0/ui-common";
	import { NDKUser, type Hexpubkey, NDKKind, zapInvoiceFromEvent, NDKZapInvoice, NDKZap, NDKEvent } from "@nostr-dev-kit/ndk";
	import { NDKEventStore } from "@nostr-dev-kit/ndk-svelte";
	import { debounce } from "@sveu/shared";
	import { onDestroy } from "svelte";
	import { Readable, derived } from "svelte/store";

    export let user: NDKUser;

	type ZapScore = { pubkey: Hexpubkey, totalSats: number, totalZaps: number, comments?: string[] };

	const sevenDaysAgoTimestamp = Math.floor((Date.now() - 7 * 24 * 60 * 60 * 1000)/1000);
	let zaps: NDKEventStore<NDKEvent> | undefined;
	let topZaps: Readable<ZapScore[]> | undefined;
	let debouncedTopZaps: ZapScore[] = [];

	let zapperPubkey: string | undefined;

	onDestroy(() => {
		zaps?.unsubscribe();
	});

	NDKZap.getZapperPubkey($ndk, user.pubkey).then((pubkey: Hexpubkey | undefined) => {
		zapperPubkey = pubkey;
		if (!zapperPubkey) return;

		zaps = $ndk.storeSubscribe(
			{ kinds: [ NDKKind.Zap], "#p": [user.pubkey], since: sevenDaysAgoTimestamp },
		);

		topZaps = derived(zaps, $zaps => {
			const receipts: NDKZapInvoice[] = [];
			const perPubkeyScore = new Map<Hexpubkey, ZapScore>();

			for (const zap of $zaps) {
				const receipt = zapInvoiceFromEvent(zap);
				if (receipt) {
					if (
						(zapperPubkey && receipt.zapper === zapperPubkey) ||
						!zapperPubkey
					) {
						receipts.push(receipt);
						const currentScore = perPubkeyScore.get(receipt.zappee) || { totalSats: 0, totalZaps: 0 };
						perPubkeyScore.set(receipt.zappee, {
							totalSats: currentScore.totalSats + receipt.amount,
							totalZaps: currentScore.totalZaps + 1,
							pubkey: receipt.zappee,
						});
					}
				}
			}

			// get the top ten pubkeys with the most amount of sats
			const sortedScores = Array.from(perPubkeyScore.entries()).sort((a, b) => b[1].totalSats - a[1].totalSats).slice(0, 5);
			return sortedScores.map(([pubkey, score]) => ({ ...score, pubkey }));
		});
	});

	const updateRenderedZaps = debounce((zaps: ZapScore[]) => {
		console.log('update it', zaps.length);
		debouncedTopZaps = zaps;
	}, 0.1, {maxWait: 0.1});

	$: if ($topZaps) {
		updateRenderedZaps($topZaps);
		console.log('updating rendered zaps', $topZaps.length);
	}
</script>

{#if debouncedTopZaps.length > 0}
	<div class="flex flex-col discussion-wrapper w-full">
		<div class="discussion-item">
			<h2 class="text-white font-semibold text-lg">
				Top Zappers
			</h2>
			<div class="text-xs font-light">
				In the last week
			</div>
		</div>

		{#each debouncedTopZaps as { pubkey, totalSats } (pubkey)}
			<UserProfile {pubkey} let:userProfile let:authorUrl>
				{#if userProfile}
					<a href={authorUrl} class="flex flex-row items-center justify-between w-full discussion-item gap-4 !py-2">
						<AvatarWithName {userProfile} avatarType="square" avatarSize="small" class="truncate" />
						<div class="text-sm font-bold">{nicelyFormattedMilliSatNumber(totalSats)}</div>
					</a>
				{/if}
			</UserProfile>
		{/each}
		<!-- <SupporterList {user} /> -->
	</div>
{/if}