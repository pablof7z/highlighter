<script lang="ts">
	import { pageHeader } from "$stores/layout";

    $pageHeader = {
        title: "Settings",
        left: {
            label: "Back",
            url: "/settings",
        },
        right: {
        }
    }
</script>

<slot />