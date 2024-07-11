<script lang="ts">
    import { currencySymbol, possibleCurrencies } from "$utils/currency";
    import * as Select from "$lib/components/ui/select";

    export let currency: string;
</script>

<Select.Root onSelectedChange={(e) => currency = e.value}>
    <Select.Trigger class="w-full">
        <Select.Value placeholder="Currency" />
    </Select.Trigger>
    <Select.Content>
        {#each possibleCurrencies as currency}
            <Select.Item value={currency}>{currencySymbol(currency)}</Select.Item>
        {/each}
    </Select.Content>
</Select.Root>