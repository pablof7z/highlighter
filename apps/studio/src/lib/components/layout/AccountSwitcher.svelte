<script lang="ts">
	import CaretSort from 'svelte-radix/CaretSort.svelte';
	import Check from 'svelte-radix/Check.svelte';
	import PlusCircled from 'svelte-radix/PlusCircled.svelte';

	import { tick } from 'svelte';
	import { cn } from '$lib/utils.js';
	import { Button } from '@components/ui/button/index.js';
	import * as Command from '@components/ui/command/index.js';
	import * as Dialog from '@components/ui/dialog/index.js';
	import Avatar from '@/components/user/Avatar.svelte';
	import Name from '@/components/user/Name.svelte';
	import { Input } from '@components/ui/input/index.js';
	import { Label } from '@components/ui/label/index.js';
	import * as Popover from '@components/ui/popover/index.js';
	import * as Select from '@components/ui/select/index.js';
	import { currentUser, currentUserProfile } from '@/state/current-user.svelte';

	let { className = undefined } = $props();

	const user = currentUser();
	const profile = currentUserProfile();

	// const groups = [
	// 	{
	// 		label: 'Personal Account',
	// 		teams: [
	// 			{
	// 				label: 'Alicia Koch',
	// 				value: 'personal'
	// 			}
	// 		]
	// 	},
	// 	{
	// 		label: 'Publications',
	// 		teams: [
	// 			{
	// 				label: 'Acme Inc.',
	// 				value: 'acme-inc'
	// 			},
	// 			{
	// 				label: 'Monsters Inc.',
	// 				value: 'monsters'
	// 			}
	// 		]
	// 	}
	// ];

	let open = $state(false);
	let showTeamDialog = $state(false);

	let selectedTeam = $state<string | null>(null);

	function closeAndRefocusTrigger(triggerId: string) {
		open = false;

		tick().then(() => document.getElementById(triggerId)?.focus());
	}
</script>

<Dialog.Root bind:open={showTeamDialog}>
	<Popover.Root>
		<Popover.Trigger>
			<Button
				variant="outline"
				role="combobox"
				aria-expanded={open}
				aria-label="Select a team"
				class={cn('w-[200px] justify-between', className)}
			>
				<Avatar {profile} size="small" />
				<Name {profile} />
				<CaretSort class="ml-auto h-4 w-4 shrink-0 opacity-50" />
			</Button>
		</Popover.Trigger>
		<Popover.Content class="w-[200px] p-0">
			<Command.Root>
				<Command.List>
					<Command.Empty>No team found.</Command.Empty>
					<Command.Group heading={'Personal Account'}>
						<Command.Item
							onSelect={() => {
								selectedTeam = 'personal';
								closeAndRefocusTrigger(ids.trigger);
							}}
							value="personal"
							class="text-sm"
						>
							<Avatar {profile} size="small" />
							<Name {profile} />
							<Check
								class={cn('ml-auto h-4 w-4', selectedTeam !== 'personal' && 'text-transparent')}
							/>
						</Command.Item>
					</Command.Group>

					<!-- {#each groups as group}
						<Command.Group heading={group.label}>
							{#each group.teams as team}
								<Command.Item
									onSelect={() => {
										selectedTeam = team.value;
										closeAndRefocusTrigger(ids.trigger);
									}}
									value={team.label}
									class="text-sm"
								>
									<Avatar.Root class="mr-2 h-5 w-5">
										<Avatar.Image src={profile.image} alt={profile.name} />
										<Avatar.Fallback>SC</Avatar.Fallback>
									</Avatar.Root>
									{team.label}
									<Check
										class={cn('ml-auto h-4 w-4', selectedTeam !== team.value && 'text-transparent')}
									/>
								</Command.Item>
							{/each}
						</Command.Group>
					{/each} -->
				</Command.List>
				<Command.Separator />
				<Command.List>
					<Command.Group>
						<Command.Item
							onSelect={() => {
								open = false;
								showTeamDialog = true;
							}}
						>
							<PlusCircled class="mr-2 h-5 w-5" />
							Create Publication
						</Command.Item>
					</Command.Group>
				</Command.List>
			</Command.Root>
		</Popover.Content>
	</Popover.Root>
	<Dialog.Content>
		<Dialog.Header>
			<Dialog.Title>Create Publication</Dialog.Title>
			<Dialog.Description>Add a new publication to manage your content and how you interact with your audience.</Dialog.Description>
		</Dialog.Header>
		<div>
			<div class="space-y-4 py-2 pb-4">
				<div class="space-y-2">
					<Label for="name">Publication Name</Label>
					<Input id="name" placeholder="Acme Inc." />
				</div>
				<div class="space-y-2">
					<Label for="plan">Subscription plan</Label>
					<Select.Root>
						<Select.Trigger>
							<Select.Value placeholder="Select a plan" />
						</Select.Trigger>
						<Select.Content>
							<Select.Item value="free">
								<span class="font-medium">Free </span>-<span class="text-muted-foreground">
									Trial for two weeks
								</span>
							</Select.Item>
							<Select.Item value="pro">
								<span class="font-medium">Pro</span> -
								<span class="text-muted-foreground"> $9/month per user </span>
							</Select.Item>
						</Select.Content>
					</Select.Root>
				</div>
			</div>
		</div>
		<Dialog.Footer>
			<Button variant="outline" onclick={() => (showTeamDialog = false)}>Cancel</Button>
			<Button type="submit">Continue</Button>
		</Dialog.Footer>
	</Dialog.Content>
</Dialog.Root>
