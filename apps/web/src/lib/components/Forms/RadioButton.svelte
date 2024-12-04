<script lang="ts">
	import { Check, CheckFat } from 'phosphor-svelte';
	import { createEventDispatcher } from 'svelte';
	import Checkbox from './Checkbox.svelte';

	export let currentValue: string | undefined = undefined;
	export let value: string | undefined = undefined;
	export let color = 'accent';

	const dispatch = createEventDispatcher();

	let selected: boolean;

	$: selected = currentValue === value;

	function onClick() {
		currentValue = value;
		dispatch('click', value);
	}
</script>

<button
	class="
    bg-secondary/30
    flex w-full flex-row items-center
    justify-between
    gap-2 rounded border-2 p-2 px-4 text-left {$$props.class ?? ''}
    {selected ? 'border-gold' : ''}
"
	on:click={onClick}
>
	<div class="flex w-full flex-row items-start">
		<div class="flex w-full flex-row items-center justify-stretch gap-10">
			<div class="flex w-full grow flex-col items-start gap-1">
				<span class="text-base font-medium {selected ? 'text-gold' : ''}"><slot /></span>
				{#if $$slots.description}
					<div class="text-muted-foreground text-sm">
						<slot name="description" />
					</div>
				{/if}
			</div>

			{#if $$slots.icon}
				<slot name="icon" />
			{/if}
		</div>
	</div>
</button>
