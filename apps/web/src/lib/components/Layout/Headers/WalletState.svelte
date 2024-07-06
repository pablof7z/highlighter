<script lang="ts">
    import CurrentUser from "$components/CurrentUser.svelte";
    import { activeWalletEvent, userProofs, userTokens, walletBalance } from "$stores/cashu";
    import { nicelyFormattedSatNumber } from "$utils";
    import { Lightning } from "phosphor-svelte";
</script>

<div class="flex items-center rounded-full w-[360px]">
    <CurrentUser class="w-16 h-16 rounded-full flex flex-row items-center" />
    <a href="/wallet" class="flex items-center justify-between flex-grow border border-secondary w-full rounded-full p-2">
        {#if $activeWalletEvent}
            <div class="flex items-center">
                <Lightning class="text-accent w-6 h-6" weight="fill" />
                <span class="text-foreground text-xl font-semibold">
                    {#if Number.isInteger($walletBalance)}
                        {nicelyFormattedSatNumber($walletBalance)} sats
                    {:else}
                        20.042
                    {/if}
                </span>
            </div>
        {/if}
    </a>
</div>
