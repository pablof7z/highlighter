<script lang="ts">
	import Section from "$components/Layout/Headers/Section.svelte";
    import { layout } from "$stores/layout";

    $layout.header = {
        component: Section,
        props: {
            title: "Wallet",
            backUrl: "/",
        }
    }

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