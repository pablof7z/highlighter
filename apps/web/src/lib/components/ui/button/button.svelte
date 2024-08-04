<script lang="ts">
	import { Button as ButtonPrimitive } from "bits-ui";
	import { type Events, type Props, buttonVariants } from "./index.js";
	import { cn } from "$lib/utils.js";
	import { appMobileView } from "$stores/app.js";
	import { createEventDispatcher, onDestroy, onMount } from "svelte";

	type $$Props = Props & {
		class?: string;
	};
	type $$Events = Events;

	let className: $$Props["class"] = undefined;
	export let variant: $$Props["variant"] = "default";
	export let size: $$Props["size"] = "default";
	export let builders: $$Props["builders"] = [];
	export { className as class };

	let localClass = "";

	$: if ($appMobileView) {
		localClass = buttonVariants.variants.variant[(variant as $$Props["variant"])]??[]
	}
</script>

<ButtonPrimitive.Root
	{builders}
	class={cn(buttonVariants({ variant, size, className }))}
	type="button"
	{...$$restProps}
	on:click
	on:keydown
>
	<slot />
</ButtonPrimitive.Root>