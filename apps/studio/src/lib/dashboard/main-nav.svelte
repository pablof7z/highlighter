<script lang="ts">
	import { page } from "$app/stores";
	import { cn } from "$lib/utils.js";
	import { cubicInOut } from "svelte/easing";
	import { crossfade } from "svelte/transition";

	let className: string | undefined | null = undefined;
	export { className as class };

	const [send, receive] = crossfade({
		duration: 250,
		easing: cubicInOut,
	});

	const items = [
		{ href: "/", name: "Posts" },
		{ href: "/settings", name: "Settings" },
		// { href: "/activity", name: "Activity" },
	];
</script>

<nav class={cn("flex items-center space-x-2 mx-6", className)}>
	{#each items as item, index}
		{@const isActive =
			($page.url.pathname.startsWith(item.href) && item.href !== "/") ||
			($page.url.pathname === "/" && index === 0)}

		<a
			href={item.href}
			data-sveltekit-noscroll
			class={cn(
					"hover:text-foreground relative flex h-7 items-center justify-center rounded-full px-4 text-center text-sm transition-colors",
					isActive ? "text-foreground font-medium" : "text-muted-foreground"
				)}
		>
			{#if isActive}
				<div
					class="bg-muted absolute inset-0 rounded-full"
					in:send={{ key: "activetab" }}
					out:receive={{ key: "activetab" }}
				/>
			{/if}
			<div class="relative">
				{item.name}
				{#if item.label}
					<span
						class="ml-2 rounded-md bg-[#adfa1d] px-1.5 py-0.5 text-xs font-medium leading-none text-[#000000] no-underline group-hover:no-underline"
					>
						{item.label}
					</span>
				{/if}
			</div>
		</a>
	{/each}
</nav>
