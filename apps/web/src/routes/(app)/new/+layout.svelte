<script lang="ts">
	import { fade } from 'svelte/transition';
	import { startUserView, userSubscription } from "$stores/user-view";
	import { user } from "@kind0/ui-common";
	import { onDestroy, onMount } from "svelte";

    let startedUserView = false;

    $: if (!!$user && !startedUserView) {
        startedUserView = true;
        startUserView($user);
    }

    onDestroy(() => {
        userSubscription?.unref();
    })
</script>

{#if startedUserView}
    <div class="mx-auto max-w-prose">
        <slot />
    </div>
{:else}
    <!-- TODO: Loading screen -->
    <div class="flex flex-col w-[90vw] h-[90vh] items-center justify-center" transition:fade>
        <div class="loading loading-lg"></div>
    </div>
{/if}