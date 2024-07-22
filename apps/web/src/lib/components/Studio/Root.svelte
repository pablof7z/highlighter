<script lang="ts">
	import currentUser from "$stores/currentUser";
    import * as User from "$components/User";
	import { setContext } from "svelte";
	import { writable } from "svelte/store";
	import { Thread } from "$utils/thread";
	import { NDKArticle, NDKVideo } from "@nostr-dev-kit/ndk";
	import { type Mode, Types, PublishInGroupStore } from ".";

    const relays = writable(new Set());
    const thread = writable<Thread | undefined>();
    const event = writable<NDKArticle | NDKVideo>();
    const mode = writable<Mode>('edit');
    const type = writable<Types>();
    const publishAt = writable<Date | undefined>();
    export let publishInGroups: PublishInGroupStore = writable(new Map());

    setContext('mode', mode);
    setContext('relays', relays);
    setContext('event', event);
    setContext('thread', thread);
    setContext('type', type);
    setContext('publishInGroups', publishInGroups);
</script>

{#if $currentUser}
    <User.Root
        user={$currentUser}
        let:groups
    >
        <slot
            {groups}
            {mode}
            {thread}
            {event}
            {type}
            {publishAt}
            {publishInGroups}
        />
    </User.Root>
{/if}