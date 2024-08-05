<script lang="ts">
	import { layout } from "$stores/layout";

    $layout = {
        title: "Settings",
        back: {
            url: "/settings",
        },
    }
</script>

<div class="responsive-padding">
    <slot />
</div>