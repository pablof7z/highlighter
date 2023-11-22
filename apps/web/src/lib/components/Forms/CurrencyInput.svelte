<script lang="ts">
	import { Input } from "@kind0/ui-common";

    export let amount: string;
    export let currency: string;
</script>

<div class="flex flex-row">
    <Input
        bind:value={amount}
        class="black"
        placeholder="Amount"
    />
    <Input
        bind:value={currency}
        class="!bg-transparent border border-neutral-800 rounded-xl text-white text-xl rounded-l-none w-24"
        placeholder="Currency"
    />
</div>