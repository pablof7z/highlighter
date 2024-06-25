<script lang="ts">
	import ModalShell from "$components/ModalShell.svelte";
    import { NDKUser } from "@nostr-dev-kit/ndk";
    import * as Tabs from "$lib/components/ui/tabs";
	import { ndk } from "$stores/ndk";
	import UserProfile from "$components/User/UserProfile.svelte";
	import { fetchEvent } from "$utils/ssr";
	import { pluralize } from "$utils";

    export let user: NDKUser;

    const item = $ndk.outboxTracker.data.get(user.pubkey);
    const writeRelays = Array.from(item?.writeRelays)
    const readRelays = Array.from(item?.readRelays)
</script>

<ModalShell title="User Info">
    <Tabs.Root value="relays" class="w-[400px]">
        <Tabs.List>
            <Tabs.Trigger value="relays">Relays</Tabs.Trigger>
            <Tabs.Trigger value="kind:0">Kind 0</Tabs.Trigger>
            <Tabs.Trigger value="kind:3">Kind 3</Tabs.Trigger>
        </Tabs.List>
        <Tabs.Content value="relays">
            <h1>Write relays</h1>
            {#each writeRelays as relay}
                <div>{relay}</div>
            {/each}

            <h1>Read relays</h1>
            {#each readRelays as relay}
                <div>{relay}</div>
            {/each}
        </Tabs.Content>

        <Tabs.Content value="kind:0">
            {#await $ndk.fetchEvent({kinds:[0], authors: [user.pubkey]})}
                <div>Loading...</div>
            {:then event}
                {#if event}
                    <pre class="whitespace-normal">{event.content}</pre>
                {/if}
            {:catch error}
                <div>Error: {error.message}</div>
            {/await}
        </Tabs.Content>

        <Tabs.Content value="kind:3">
            {#await $ndk.fetchEvent({kinds:[3], authors: [user.pubkey]})}
                <div>Loading...</div>
            {:then event}
                {#if event}
                    <p>Follows: {event.tags.filter(t => t[0] === "p").length}</p>
                    <pre>{JSON.stringify(event.tags, null, 4)}</pre>
                {/if}
            {:catch error}
                <div>Error: {error.message}</div>
            {/await}
        </Tabs.Content>
        
    </Tabs.Root>
</ModalShell>