<script lang="ts">
    import { layout } from "$stores/layout";
    
    $layout.title = "Reads";
    $layout.back = { url: "/" };
    $layout.fullWidth = false;
    $layout.sidebar = false;

    $layout.navigation = [
        { value: "", name: "👋 Newest", href: '/reads' },
        { name: "🌟 Top", href: '/reads/top' },
        { name: "🔥 Hot", href: '/reads/hot' },
        { name: "📚 Curations", href: '/reads/curations' },
    ]

    $layout.activeOption = $layout.navigation[0];
</script>

<slot />