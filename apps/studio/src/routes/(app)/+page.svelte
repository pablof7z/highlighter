<script lang="ts">
	import { Button } from '@/components/ui/button';
	import * as Tabs from '@/components/ui/tabs';
	import ImportModal from '@/components/Import/Modal.svelte';
	import { ndk } from '@/state/ndk';
	import { currentUser } from '@/state/current-user.svelte';
	import { NDKArticle, NDKDraft, NDKDVMRequest, NDKEvent, NDKKind, NDKSubscriptionCacheUsage, NDKUser } from '@nostr-dev-kit/ndk';
	import NewPost from '@/components/buttons/new-post.svelte';
	import List from '@/components/lists/index.svelte';
	import { Badge } from '@/components/ui/badge/index.js';
	import { Calendar } from 'svelte-radix';
	import { goto } from '$app/navigation';

	const user = currentUser() as NDKUser;

	const posts = ndk.$subscribe([{ kinds: [NDKKind.Article], authors: [user.pubkey] }]);

	const allDrafts = ndk.$subscribe(
		[{ kinds: [NDKKind.Draft], '#k': [NDKKind.Article.toString()], authors: [user.pubkey] }],
		{ groupable: false, subId: 'drafts' },
		NDKDraft
	);

	const draftIsMine = (d: NDKDraft) => {
		const pTag = d.tagValue('p');
		return (!pTag || pTag === user.pubkey);
	}
	
	const drafts = $derived.by(() => allDrafts.filter(draftIsMine));

	const inboundProposals = ndk.$subscribe(
		[{ kinds: [NDKKind.Draft], '#k': [NDKKind.Article.toString()], '#p': [user.pubkey] }],
		undefined,
		NDKDraft
	);

	const outboundProposals = $derived.by(() => allDrafts.filter((d) => !draftIsMine(d)));

	const allProposals = $derived.by(() => [...inboundProposals, ...outboundProposals]);

	const deletes = ndk.$subscribe([
		{
			kinds: [NDKKind.EventDeletion],
			'#k': [NDKKind.Article.toString(), NDKKind.Draft.toString()],
			authors: [user.pubkey]
		}
	]);

	const scheduled = ndk.$subscribe(
		[{ kinds: [NDKKind.DVMEventSchedule], authors: [user.pubkey] }],
		undefined,
		NDKDVMRequest
	);

	let importModal = $state(false);
	let twoColumns = $state(false);

	let viewEvent = $state<NDKEvent | null>(null);
</script>

<div class="mx-auto w-full transition-all duration-300"
	class:two-columns={twoColumns}
	class:one-column={!twoColumns}
>
	<main>
		<div class="flex items-center justify-between space-y-2 mb-4">
			<h2 class="text-3xl font-bold tracking-tight">Posts</h2>
			<div class="flex items-center space-x-2">
				<NewPost variant="secondary" onImport={() => (importModal = true)} />
			</div>
		</div>

		<Tabs.Root value="published" class="space-y-4">
			<Tabs.List>
				<Tabs.Trigger value="published">
					Published
					<Badge class="ml-2" variant="secondary">{posts.length}</Badge>
				</Tabs.Trigger>
				<Tabs.Trigger value="drafts">
					Drafts
					<Badge class="ml-2" variant="secondary">{drafts.length}</Badge>
				</Tabs.Trigger>
				<Tabs.Trigger value="proposals">
					Proposed
					<Badge class="ml-2" variant="secondary">{allProposals.length}</Badge>
				</Tabs.Trigger>
				<Tabs.Trigger value="scheduled">
					Scheduled
					<Badge class="ml-2" variant="secondary">{scheduled.length}</Badge>
				</Tabs.Trigger>
			</Tabs.List>

			<Tabs.Content value="published" class="space-y-4">
				{#if posts.length === 0}
					<div class="text-muted-foreground flex h-full flex-col items-center justify-center gap-4 p-10 text-sm">
						<Calendar class="h-12 w-12" />
						You don't have any published posts yet!

						<div class="flex flex-row gap-2">
							<Button variant="outline" onclick={() => goto('/article/new')}>New Post</Button>
							<Button variant="outline" onclick={() => (importModal = true)}>
								Import your content
							</Button>
						</div>
					</div>
				{:else}
					<List events={posts} />
				{/if}
			</Tabs.Content>

			<Tabs.Content value="drafts" class="space-y-4">
				<List events={drafts} />
			</Tabs.Content>

			<Tabs.Content value="proposals" class="space-y-4">
				<List events={allProposals} />
			</Tabs.Content>

			<Tabs.Content value="scheduled">
				{#if scheduled.length === 0}
					<div class="text-muted-foreground flex h-full flex-col items-center justify-center gap-4 p-10 text-sm">
						<Calendar class="h-12 w-12" />
						You don't have any scheduled posts yet!
					</div>
				{:else}
					<List events={scheduled} />
				{/if}
			</Tabs.Content>
		</Tabs.Root>
	</main>

	{#if twoColumns && viewEvent}
		{@const article = NDKArticle.from(viewEvent)}
		<div class="col-span-2 p-8 article max-w-prose">
			<h1>{article.title}</h1>
			<div class="text-muted-foreground">
				{viewEvent.content}
			</div>
		</div>
	{/if}
</div>

<ImportModal bind:open={importModal} />

<style lang="postcss">
	.one-column {
		@apply max-w-5xl;
	}
	
	.two-columns {
		@apply grid grid-cols-3 gap-4;
	}
</style>
