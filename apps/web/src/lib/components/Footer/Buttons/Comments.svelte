<script lang="ts">
	import { getEventUrl } from '$utils/url';
	import { goto } from '$app/navigation';
	import ReplyAvatars from './../../Feed/ReplyAvatars.svelte';
	import { ndk } from '$stores/ndk.js';
	import { ChatCircle } from 'phosphor-svelte';
	import ButtonWithCount from '$components/buttons/ButtonWithCount.svelte';
	import { NDKEvent, NDKKind } from '@nostr-dev-kit/ndk';
	import { onDestroy } from 'svelte';
	import { derived } from 'svelte/store';
	import { isEventShare } from '$utils/event';

    export let event: NDKEvent;

    const replies = $ndk.storeSubscribe([
        { kinds: [NDKKind.Text, NDKKind.GroupNote], ...event.filter() },
        { kinds: [1111], ...event.filter() },
    ])
    const replieWithoutShares = derived(replies, ($replies) => $replies.filter((reply) => !isEventShare(reply, event)));

    onDestroy(() => {
        replies.unsubscribe();
    });

    const users = derived(replieWithoutShares, ($replieWithoutShares) => $replieWithoutShares.map((reply) => reply.pubkey));

    function clicked() {
        goto(getEventUrl(event, undefined, 'comments'));
    }
</script>

<ButtonWithCount
    count={$replieWithoutShares.length}
    class="gap-3 hover:bg-teal-500/20 group rounded-full text-muted-foreground"
    on:click={clicked}
>
    <ChatCircle size={20} weight="bold" class="transition-all duration-100 group-hover:text-teal-500" />
    <svelte:fragment slot="after">
            <ReplyAvatars users={$users} size="xs" />
    </svelte:fragment>
</ButtonWithCount>
