<script lang="ts">
	import Activity from 'lucide-svelte/icons/activity';
	import CreditCard from 'lucide-svelte/icons/credit-card';
	import DollarSign from 'lucide-svelte/icons/dollar-sign';
	import Download from 'lucide-svelte/icons/download';
	import Users from 'lucide-svelte/icons/users';
	import {
		DashboardMainNav,
		Overview,
		RecentSales,
		Search,
		TeamSwitcher,
		UserNav
	} from './index.js';
	import * as Card from '@/components/ui/card';
	import * as Tabs from '@/components/ui/tabs';
	import DashboardLight from '@/img/dashboard-light.png?enhanced';
	import DashboardDark from '@/img/dashboard-dark.png?enhanced';
	import { ndk } from '@/state/ndk';
	import { currentUser } from '@/state/current-user.svelte';
	import { NDKDraft, NDKKind, NDKUser } from '@nostr-dev-kit/ndk';
	import NewPost from '@/components/buttons/new-post.svelte';
	import List from '@/components/lists/index.svelte';
	import { Badge } from '@/components/ui/badge/index.js';

	const user = currentUser() as NDKUser;

	const posts = ndk.$subscribe([{ kinds: [NDKKind.Article], authors: [user.pubkey] }]);

	const drafts = ndk.$subscribe(
		[{ kinds: [NDKKind.Draft], '#k': [NDKKind.Article.toString()], authors: [user.pubkey] }],
		undefined,
		NDKDraft
	);

	const proposals = ndk.$subscribe([
		{ kinds: [NDKKind.Draft], '#k': [NDKKind.Article.toString()], '#p': [user.pubkey] }
	]);
</script>

<div class="md:hidden">
	<enhanced:img src={DashboardLight} alt="Dashboard" class="block dark:hidden" />
	<enhanced:img src={DashboardDark} alt="Dashboard" class="hidden dark:block" />
</div>
<div class="hidden flex-col md:flex">
	<div class="border-b">
		<div class="flex h-16 items-center px-4">
			<TeamSwitcher />
			<DashboardMainNav class="mx-6" />
			<div class="ml-auto flex items-center space-x-4">
				<Search />
				<UserNav />
			</div>
		</div>
	</div>

	<div class="mx-auto w-full max-w-5xl flex-1 space-y-4 p-8 pt-6">
		<div class="flex items-center justify-between space-y-2">
			<h2 class="text-3xl font-bold tracking-tight">Posts</h2>
			<div class="flex items-center space-x-2">
				<NewPost />
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
				<Tabs.Trigger value="archived">
					Proposed

					<Badge class="ml-2" variant="secondary">{proposals.length}</Badge>
				</Tabs.Trigger>
				<Tabs.Trigger value="scheduled">Scheduled</Tabs.Trigger>
			</Tabs.List>
			<Tabs.Content value="published" class="space-y-4">
				<List events={posts} />
			</Tabs.Content>

			<Tabs.Content value="drafts" class="space-y-4">
				<List events={drafts} />
			</Tabs.Content>
		</Tabs.Root>
	</div>
</div>
