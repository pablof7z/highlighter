<script lang="ts">
	import { Button } from '@components/ui/button';
	import { toggleMode } from 'mode-watcher';
	import { Moon, Sun } from 'svelte-radix';

	export let variant = 'secondary';
</script>

<Button
	class="flex flex-none flex-row items-center gap-2 {$$props.class ?? ''}"
	onclick={toggleMode}
	{variant}
	size={$$slots.default ? 'default' : 'icon'}
>
	<Sun class="h-[1.2rem] w-[1.2rem] transition-all dark:hidden" weight="fill" />
	<Moon class="hidden h-[1.2rem] w-[1.2rem] transition-all dark:block" weight="fill" />
	<slot />
	<span class="sr-only">Toggle theme</span>
</Button>
