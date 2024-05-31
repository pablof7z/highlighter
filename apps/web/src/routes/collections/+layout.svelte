<script lang="ts">
	import { pageHeader } from "$stores/layout";

    $pageHeader ??= {};
    $pageHeader.subNavbarOptions = [
        { name: "Bookmarks", href: "/bookmarks" },
        { name: "Collections", href: "/collections" },
    ];
</script>

<slot />