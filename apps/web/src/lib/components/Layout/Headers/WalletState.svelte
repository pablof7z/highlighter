<script lang="ts">
    import { defaultWalletBalance } from "$stores/cashu";
    import { nicelyFormattedSatNumber } from "$utils";
    import { Lightning } from "phosphor-svelte";


</script>

<a href="/wallet" class="flex items-center justify-between flex-grow border border-secondary w-full rounded-full p-2">
    <div class="flex items-center">
        <Lightning class="text-accent w-6 h-6" weight="fill" />
        <span class="text-foreground text-xl font-semibold">
            {nicelyFormattedSatNumber($defaultWalletBalance)} sats
        </span>
    </div>
</a>