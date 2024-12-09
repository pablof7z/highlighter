<script lang="ts">
	import { cn } from "$lib/utils.js";

	let className: string | undefined | null = undefined;
	export { className as class };
</script>

<nav class={cn("flex items-center space-x-4 lg:space-x-6", className)}>
	<a href="/" class="hover:text-primary text-sm font-medium transition-colors">
		Posts
	</a>
	<a
		href="/examples/dashboard"
		class="text-muted-foreground hover:text-primary text-sm font-medium transition-colors"
	>
		Subscribers
	</a>
	<a
		href="/examples/dashboard"
		class="text-muted-foreground hover:text-primary text-sm font-medium transition-colors"
	>
		Recommendations
	</a>
</nav>
