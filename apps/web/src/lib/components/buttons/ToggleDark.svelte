<script lang="ts">
	import { Button } from "$components/ui/button";
	import { toggleMode } from "mode-watcher";
	import { Sun, Moon } from "phosphor-svelte";

    export let variant = "secondary";
</script>

<Button class="flex flex-row items-center gap-2 flex-none {$$props.class??""}" on:click={toggleMode} {variant} size={$$slots.default ? "default" : "icon" }>
    <Sun class="h-[1.2rem] w-[1.2rem] transition-all dark:hidden" weight="fill" />
    <Moon class="h-[1.2rem] w-[1.2rem] transition-all hidden dark:block" weight="fill" />
    <slot />
    <span class="sr-only">Toggle theme</span>
</Button>