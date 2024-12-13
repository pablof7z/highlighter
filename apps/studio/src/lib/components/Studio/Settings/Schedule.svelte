<script lang="ts">
	import Input from '@/components/ui/input/input.svelte';
	import type { PostState } from '../state.svelte';
	import Button from '@/components/ui/button/button.svelte';
	import { Calendar1, Timer, X } from 'lucide-svelte';
	import { Calendar } from 'svelte-radix';
	import { Separator } from '@/components/ui/separator';

	interface Props {
		postState: PostState;
	}

	let { postState = $bindable() }: Props = $props();

	let value = $state(postState.publishAt);
</script>

<div class="flex flex-col gap-2">
	{#if postState.publishAt}
		<div class="flex flex-col items-center justify-center p-4">
			<div
				class="bg-secondary flex w-fit flex-col items-center justify-center gap-4 rounded-lg p-4"
			>
				<Calendar size={48} class="text-muted-foreground" />

				<div class="flex flex-col items-center text-sm">
					<div class="text-muted-foreground">Will publish on</div>
					<span class="text-foreground text-lg font-medium">
						{new Date(postState.publishAt).toLocaleString()}
					</span>
				</div>
			</div>
		</div>
	{/if}

	<div class="flex flex-row gap-2">
		<Input type="datetime-local" bind:value />
		<Button variant="secondary" onclick={() => (postState.publishAt = value)}>
			Set Publish Date
		</Button>
	</div>

	{#if postState.publishAt}
		<div class="flex justify-center">
			<Button
				variant="ghost"
				class="text-xs w-fit"
				size="sm"
				onclick={() => (postState.publishAt = null)}
			>
				Remove scheduled date
			</Button>
		</div>
	{/if}
</div>
