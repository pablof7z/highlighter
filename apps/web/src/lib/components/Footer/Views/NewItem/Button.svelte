<script lang="ts">
	import { Plus } from 'phosphor-svelte';
	import { Button } from "$components/ui/button";
</script>

<Button
    variant="accent"
    class="flex-none max-sm:w-12 w-10 max-sm:h-12 h-10 p-2"
    on:click
>
    <Plus class="w-full h-full" weight="bold" />
</Button>