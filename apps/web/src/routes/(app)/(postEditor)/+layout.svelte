<script lang="ts">
	import { startUserView, userSubscription } from "$stores/user-view";
	import { user } from "@kind0/ui-common";
	import { onDestroy, onMount } from "svelte";
	import LoadingScreen from '$components/LoadingScreen.svelte';

    let startedUserView = false;
    let mounted = false;

    onMount(() => {
        mounted = true;
    });

    $: if (!!$user && !startedUserView && mounted) {
        startedUserView = true;
        startUserView($user);
    }

    onDestroy(() => {
        userSubscription?.unref();
    })
</script>

<LoadingScreen ready={!!startedUserView}>
    <div class="mx-auto max-w-3xl">
        <slot />
    </div>
</LoadingScreen>
