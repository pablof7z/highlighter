<script lang="ts">
	import { startUserView, userSubscription } from "$stores/user-view";
	import currentUser from "$stores/currentUser";
	import { onMount, onDestroy } from "svelte";
	import { layoutMode, resetLayout } from "$stores/layout";

    let startedUserView = false;
    let mounted = false;

    $layoutMode = "single-column-focused";

    onMount(() => {
        mounted = true;
    });

    $: if (mounted && $currentUser && !startedUserView) {
        startUserView($currentUser);
        startedUserView = true;
    }

    onDestroy(() => {
        userSubscription?.unref();
        resetLayout();
    })
</script>

<slot />