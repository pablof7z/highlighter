<script lang="ts">
    import { layout } from "$stores/layout";

    $layout = {
        title: "Wallet",
        sidebar: false,
        fullWidth: false,

        navigation: [
            { name: "Overview", href: "/wallet" },
            { name: "Tokens", href: "/wallet/tokens" },
            { name: "History", href: "/wallet/history" },
        ],
    }
</script>

<div class="resposive-padding py-6">
    <slot />
</div>