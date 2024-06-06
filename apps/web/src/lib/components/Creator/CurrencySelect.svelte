<script lang="ts">
    import { currencySymbol, possibleCurrencies } from "$utils/currency";

    export let currency: string;
</script>

<select class="select pr-10 pl-0 text-right bg-foreground/10 text-foreground border border-border {$$props.class??""}" bind:value={currency}>
    {#if !currency}
        <option value="" selected>select currency</option>
    {/if}
    {#each possibleCurrencies as currency}
        <option value={currency}>{currencySymbol(currency)}</option>
    {/each}
</select>