<script lang="ts">
    import { currencyName, currencySymbol, possibleCurrencies } from "$utils/currency";
    import * as Select from "$lib/components/ui/select";

    export let currency: string;
</script>

<Select.Root portal={null} onSelectedChange={(e) => currency = e.value}>
    <Select.Trigger class="min-w-64 w-fit {$$props.class??""}">
        <Select.Value placeholder={currency} />
    </Select.Trigger>
    <Select.Content>
        {#each possibleCurrencies as c}
            <Select.Item value={c}>{currencyName(c)}</Select.Item>
        {/each}
    </Select.Content>
</Select.Root>