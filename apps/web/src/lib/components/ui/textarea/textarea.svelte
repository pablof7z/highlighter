<script lang="ts">
	import type { HTMLTextareaAttributes } from "svelte/elements";
	import type { TextareaEvents } from "./index.js";
	import { cn } from "$lib/utils.js";
	import { createEventDispatcher, onDestroy, onMount } from "svelte";
	import { attach } from "@frsource/autoresize-textarea";

	type $$Props = HTMLTextareaAttributes;
	type $$Events = TextareaEvents 

	let className: $$Props["class"] = undefined;
	export let value: $$Props["value"] = undefined;
	export { className as class };

	// Workaround for https://github.com/sveltejs/svelte/issues/9305
	// Fixed in Svelte 5, but not backported to 4.x.
	export let readonly: $$Props["readonly"] = undefined;
	export let element: HTMLTextAreaElement | undefined = undefined;

	const dispatch = createEventDispatcher();
	
	function keydown(event: KeyboardEvent) {
		if (event.key === "Enter" && event.metaKey) {
			dispatch("submit");
		} else {
			dispatch("keydown", event);
		}

	}

	let detach: () => void;

	onMount(() => {
		if (element) {
			detach = attach(element).detach;
		}
	})

	onDestroy(() => {
		detach?.();
	})
</script>

<textarea
	bind:this={element}
	class={cn(
		"flex w-full rounded-md border border-input bg-background px-3 py-2 text-sm ring-offset-background placeholder:text-muted-foreground focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:cursor-not-allowed disabled:opacity-50",
		className
	)}
	bind:value
	{readonly}
	on:blur
	on:change
	on:click
	on:focus
	on:keydown={keydown}
	on:keypress
	on:keyup
	on:mouseover
	on:mouseenter
	on:mouseleave
	on:paste
	on:input
	{...$$restProps}
></textarea>
