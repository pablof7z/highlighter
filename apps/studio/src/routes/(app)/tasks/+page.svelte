<script lang="ts">
	import { ndk } from '@/state/ndk';
	import { getReplyTag, type NDKEvent } from '@nostr-dev-kit/ndk';
	import * as Table from '$lib/components/ui/table/index.js';
	import Avatar from '@/components/user/Avatar.svelte';
	import { EventContent } from '@nostr-dev-kit/ndk-svelte-components';

	let events = $state<NDKEvent[]>([]);
	let knownIds = $state<Set<string>>(new Set());
	let fetchEvents = $state<Set<string>>(new Set());
	let eosed = $state(false);

	let ops = $state<NDKEvent[]>([]);

	function process(eventIds: string[]) {
		ndk.fetchEvents({ ids: eventIds }).then((events) => {
			ops.push(...events);
		});
	}

	const tasks = ndk.subscribe(
		[{ '#t': ['olasbugs', 'olastodo', 'bugs'] }],
		undefined,
		undefined,
		false
	);
	tasks.on('event', (event) => {
		if (eosed) {
			process([event.id]);
		} else {
			if (!knownIds.has(event.id)) {
				knownIds.add(event.id);
				events.push(event);
			}
		}
	});
	tasks.on('eose', () => {
		eosed = true;
		const allTaggedEvents = events
			.map((e) => {
				let id = getReplyTag(e)?.[1];
				if (!id) id = e.id;
				return id;
			})
			.filter((t) => t !== undefined);
		process(Array.from(allTaggedEvents));
	});
	tasks.start();
</script>

<div>
	<Table.Root>
		<Table.Caption>A list of your recent invoices.</Table.Caption>
		<Table.Header>
			<Table.Row>
				<Table.Head class="w-[100px]">Invoice</Table.Head>
				<Table.Head>Status</Table.Head>
				<Table.Head>Method</Table.Head>
				<Table.Head class="text-right">Amount</Table.Head>
			</Table.Row>
		</Table.Header>
		<Table.Body>
			{#each ops as op}
				<Table.Row>
					<Table.Cell class="font-medium">
						<Avatar of={op.pubkey} />
					</Table.Cell>
					<Table.Cell>
						<div class="!h-10 overflow-clip">
							<EventContent {ndk} event={op} />
						</div>
					</Table.Cell>
				</Table.Row>
			{/each}
		</Table.Body>
	</Table.Root>
</div>
