<script lang="ts">
	import { getContext } from "svelte";
	import { Writable } from "svelte/store";

    const editorElement = getContext('editorElement') as Writable<HTMLDivElement | null>;
</script>

<div class="h-full w-full min-h-[10rem] flex items-stretch {$$props.class??""}" bind:this={$editorElement} />