<script lang="ts">
    import { ndk, user } from "@kind0/ui-common";
	import CreatorActivityItem from "./CreatorActivityItem.svelte";
	import UserProfile from "$components/User/UserProfile.svelte";
	import { onDestroy } from "svelte";

    const events = $ndk.storeSubscribe(
        { kinds: [11, 12, 7, 9735], "#h": [$user?.pubkey] }
    )

    onDestroy(() => {
        events.unsubscribe();
    })

    let authorUrl: string;
</script>

<UserProfile user={$user} bind:authorUrl />

<div class="flex flex-col gap-3">
    {#each $events as event (event.id)}
        <CreatorActivityItem {event} creatorUrl={authorUrl} />
    {/each}
</div>