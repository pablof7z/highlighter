<script lang="ts">
	import { layout } from "$stores/layout";

    $layout ??= {};
    $layout.navigation = [
        { name: "Bookmarks", href: "/bookmarks" },
        { name: "Collections", href: "/collections" },
    ];
</script>

<slot />