<script lang="ts">
	import { page } from "$app/stores";
	import ndk from "$stores/ndk";
	import { NDKAppHandlerEvent, type NDKUser } from "@nostr-dev-kit/ndk";
	import DvmCard from "$components/dvms/DvmCard.svelte";
	import { UserCard } from "@nostr-dev-kit/ndk-svelte-components";
	import type { NDKEventStore } from "@nostr-dev-kit/ndk-svelte";

    let npub: string;
    let user: NDKUser;
	let nip89events: NDKEventStore<NDKAppHandlerEvent>;

    $: if (npub !== $page.params.id) {
		npub = $page.params.id;
		user = $ndk.getUser({npub});

		nip89events = $ndk.storeSubscribe<NDKAppHandlerEvent>({
			kinds: [31990 as number],
			authors: [user.pubkey],
		}, {closeOnEose: true}, NDKAppHandlerEvent);
	}
</script>

<div class="max-w-5xl mx-auto">
	<UserCard ndk={$ndk} {user} />

	{#if $nip89events}
		{#each $nip89events as nip89event (nip89event.id)}
			<DvmCard {user} {nip89event} />
		{/each}
	{/if}
</div>

<style>
	:global(.userCard--name) {
		@apply text-base-100-content text-2xl font-semibold;
	}

	:global(.userCard--npub) {
		@apply text-xs;
	}
</style>