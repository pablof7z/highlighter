<script lang="ts">
    import { layout } from "$stores/layout";

    $layout = {
        title: "Wallet",

        navigation: [
            { name: "Overview", href: "/wallet" },
            { name: "Tokens", href: "/wallet/tokens" },
            { name: "History", href: "/wallet/history" },
        ],
    }
</script>

<div class="max-w-xl mx-auto w-full">
    <slot />
</div>