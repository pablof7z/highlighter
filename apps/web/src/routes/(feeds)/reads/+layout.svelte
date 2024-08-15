<script lang="ts">
    import { layout } from "$stores/layout";
	import { Plus } from "phosphor-svelte";
    
    $layout.title = "Reads";
    $layout.back = { url: "/" };
    $layout.fullWidth = false;
    $layout.sidebar = false;
    $layout.iconUrl = undefined;

    $layout.navigation = [
        { value: "", name: "👋 Newest", href: '/reads' },
        { name: "🌟 Top", href: '/reads/top' },
        { name: "🔥 Hot", href: '/reads/hot' },
        { name: "📚 Curations", href: '/reads/curations' },
        // { name: "Feed Marketplace", icon: Plus, buttonProps: { class: 'place-self-end', variant: 'secondary' }, href: '/reads/dvms' },
    ]

    $layout.activeOption = $layout.navigation[0];
</script>

<slot />