<script lang="ts">
	import { getSaveForLaterListForEvent } from "$actions/Events/save-for-later";
    import { layout } from "$stores/layout";
	import { ndk } from "$stores/ndk";
	import { NDKArticle } from "@nostr-dev-kit/ndk";
    
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