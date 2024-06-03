<script lang="ts">
	import { currencySymbol } from "$utils/currency";
	import { Pencil, Plus } from "phosphor-svelte";

</script>

<button class="flex-grow h-full min-h-[300px] bg-neutral-100 w-[250px] text-neutral-600 rounded-xl flex flex-col items-center justify-center gap-6 flex-grow" on:click>
    <Plus class="" size={48} weight="bold" />

    <div class="text-xl font-normal">Add a tier</div>
</button>