<script lang="ts">
	import { Button as ButtonPrimitive } from "bits-ui";
	import { type Events, type Props, buttonVariants } from "./index.js";
	import { cn } from "$lib/utils.js";
	import { appMobileView } from "$stores/app.js";
	import { Button as MobileButton } from "konsta/svelte";
	import { createEventDispatcher } from "svelte";

	const dispatcher = createEventDispatcher();

	type $$Props = Props;
	type $$Events = Events;

	let className: $$Props["class"] = undefined;
	export let variant: $$Props["variant"] = "default";
	export let size: $$Props["size"] = "default";
	export let builders: $$Props["builders"] = [];
	export { className as class };
	export let forceNonMobile: boolean = true;

	let localClass = "";

	$: if ($appMobileView) {
		localClass = buttonVariants.variants.variant[(variant as $$Props["variant"])]??[]
	}
</script>

{#if $appMobileView && !forceNonMobile}
	{#if variant === "outline"}
		<MobileButton outline onClick={(e) => dispatcher("click", e)} {...$$props} class={cn(localClass, $$props.class)}><slot /></MobileButton>
	{:else}
		<MobileButton onClick={(e) => dispatcher("click", e)} {...$$props} class={cn(localClass, $$props.class)}><slot /></MobileButton>
	{/if}
{:else}
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
{/if}