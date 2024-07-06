<script lang="ts">
	import { walletEvents } from "$stores/cashu";
import { layout } from "$stores/layout";

    $layout = {
        title: "Wallet",
        navigation: [
            { name: "Overview", href: "/wallet" },
            { name: "Tokens", href: "/wallet/tokens" },
            { name: "History", href: "/wallet/history" },
        ]
    }
</script>

<div class="max-w-xl w-full">
    <slot />
</div>