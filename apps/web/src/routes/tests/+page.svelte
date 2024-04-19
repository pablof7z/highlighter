<script lang="ts">
	import { sidebarPlacement } from "$stores/layout";
	import { pageDrawerToggle } from "@kind0/ui-common";

    function openDrawer(pos: "left" | "right") {
        $sidebarPlacement = pos;
        $pageDrawerToggle = true;
    }
</script>

<h1>Page Drawer</h1>

<button class="button" on:click={() => openDrawer('left')}>Open Left</button>
<button class="button" on:click={() => openDrawer('right')}>Open Right</button>

