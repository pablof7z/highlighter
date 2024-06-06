<script lang="ts">
	import { startUserView, userSubscription } from "$stores/user-view";
	import currentUser from "$stores/currentUser.js";
	import { onDestroy, onMount } from "svelte";
	import { goto } from "$app/navigation";

    onMount(() => {
        if (!$currentUser) {
            goto("/");
            return;
        }
        
        startUserView($currentUser);
    });

    onDestroy(() => {
        userSubscription?.unref();
    })
</script>

<slot />
