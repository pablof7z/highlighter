<script lang="ts" module>
	import type { WithElementRef } from "bits-ui";
	import type { HTMLAnchorAttributes, HTMLButtonAttributes } from "svelte/elements";
	import { type VariantProps, tv } from "tailwind-variants";

	export const buttonVariants = tv({
		base: "ring-offset-background focus-visible:ring-ring inline-flex items-center justify-center gap-2 whitespace-nowrap rounded-md text-sm font-medium transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-offset-2 disabled:pointer-events-none disabled:opacity-50 [&_svg]:pointer-events-none [&_svg]:size-4 [&_svg]:shrink-0",
		variants: {
			variant: {
				default: "bg-primary text-primary-foreground hover:bg-primary/90",
				destructive: "bg-destructive text-destructive-foreground hover:bg-destructive/90",
				outline:
					"border-input bg-background hover:bg-accent hover:text-accent-foreground border",
				secondary: "bg-secondary text-secondary-foreground hover:bg-secondary/80",
				ghost: "hover:bg-accent hover:text-accent-foreground",
				link: "text-primary underline-offset-4 hover:underline",
			},
			size: {
				default: "h-10 px-4 py-2",
				sm: "h-9 rounded-md px-3",
				lg: "h-11 rounded-md px-8",
				icon: "h-10 w-10",
			},
		},
		defaultVariants: {
			variant: "default",
			size: "default",
		},
	});

	export type ButtonVariant = VariantProps<typeof buttonVariants>["variant"];
	export type ButtonSize = VariantProps<typeof buttonVariants>["size"];

	export type ButtonStatus = "initial" | "loading" | "success" | "error";

	export type ButtonProps = WithElementRef<HTMLButtonAttributes> &
		WithElementRef<HTMLAnchorAttributes> & {
			variant?: ButtonVariant;
			size?: ButtonSize;
			status?: ButtonStatus;
		};
</script>

<script lang="ts">
	import { cn } from "$lib/utils.js";
	import { CircleCheck, Loader2, OctagonX } from "lucide-svelte";
	import { slide } from 'svelte/transition';

	let {
		class: className,
		variant = "default",
		size = "default",
		ref = $bindable(null),
			href = undefined,
			type = "button",
			status = "initial",
			children,
			...restProps
	}: ButtonProps = $props();

	let forceWidth = $state<number | undefined | null>(null);
	let width = $state<number | undefined | null>(null);

	$effect(() => {
		if (status === 'initial') {
			width = ref?.getBoundingClientRect().width;
		}

		if (status !== 'initial' && !forceWidth) {
			forceWidth = width;
		} else if (status === 'initial' && forceWidth) {
			forceWidth = null;
		}
	})

	$effect(() => {
		if (status === 'success' || status === 'error') {
			setTimeout(() => {
				status = 'initial'
			}, 5000)
		}
	})
</script>

{#if href}
	<a
		bind:this={ref}
		class={cn(buttonVariants({ variant, size, className }))}
		{href}
		{...restProps}
	>
		{@render children?.()}
	</a>
{:else}
	<button
		bind:this={ref}
		class={cn(buttonVariants({ variant, size, className }))}
		{type}
		style={forceWidth ? `width: ${forceWidth}px` : undefined}
		disabled={status === 'loading'}
		{...restProps}
	>
		{#if status === 'initial'}
			{@render children?.()}
		{:else}
			<div class="flex flex-col items-center w-full">
				{#if status === 'loading'}
					<span transition:slide>
						<Loader2 class="h-4 col-4 animate-spin" />
					</span>
				{:else if status === 'success'}
					<span transition:slide>
						<CircleCheck class="h-8 w-8" strokeWidth={3} />
					</span>
				{:else if status === 'error'}
					<span transition:slide>
						<OctagonX class="h-8 w-8" strokeWidth={3} />
					</span>
				{/if}
			</div>
		{/if}
	
	</button>
{/if}
