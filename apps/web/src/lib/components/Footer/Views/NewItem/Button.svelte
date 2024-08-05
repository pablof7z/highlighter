<script lang="ts">
	import { Plus } from 'phosphor-svelte';
	import { Button } from "$components/ui/button";
</script>

<Button
    variant="default"
    class="flex-none max-sm:w-10 w-10 max-sm:h-10 h-10 p-2 rounded-full"
    on:click
>
    <Plus class="w-full h-full" weight="bold" />
</Button>