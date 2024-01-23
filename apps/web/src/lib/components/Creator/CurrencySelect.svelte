<script lang="ts">
    import { currencySymbol, possibleCurrencies } from "$utils/currency";

    export let currency: string;
</script>

<select class="select bg-base-200 text-white border border-base-300 {$$props.class??""}" bind:value={currency}>
    {#if !currency}
        <option value="" selected>select currency</option>
    {/if}
    {#each possibleCurrencies as currency}
        <option value={currency}>{currencySymbol(currency)}</option>
    {/each}
</select>