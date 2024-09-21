<script lang="ts">
    import { layout } from "$stores/layout";

    $layout = {
        title: "Wallet",
        sidebar: false,
        fullWidth: false,
    }
</script>

<div class="resposive-padding py-6">
    <slot />
</div>