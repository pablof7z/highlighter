<script lang="ts">
    import { walletService } from "$stores/wallet";
 	import { onMount } from "svelte";
	import { toast } from "svelte-sonner";

    onMount(() => {
        $walletService.on("nutzap:redeemed", nutzapRedeemed);
    })

    function nutzapRedeemed(nutzap: NDKNutzap) {
        console.log('nutzap', nutzap.rawEvent())
        toast.success(`Nutzap redeemed: ${nutzap.amount} sats`);
    }
</script>