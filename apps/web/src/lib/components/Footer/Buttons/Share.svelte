<script lang="ts">
	import { Eye } from 'phosphor-svelte';
	import { Export } from 'phosphor-svelte';
	import { getEventUrl } from '$utils/url';
	import { BookmarkSimple, ArrowsClockwise } from 'phosphor-svelte';
	import { ndk } from '$stores/ndk.js';
	import ButtonWithCount from '$components/buttons/ButtonWithCount.svelte';
	import { NDKEvent, NDKKind } from '@nostr-dev-kit/ndk';
	import { onDestroy } from 'svelte';
	import { derived } from 'svelte/store';
	import ReplyAvatars from '../../Feed/ReplyAvatars.svelte';
    import * as HoverCard from "$lib/components/ui/hover-card";
	import { Button } from '$components/ui/button';
	import currentUser from '$stores/currentUser';
	import { toast } from 'svelte-sonner';
	import { openModal } from '$utils/modal';
	import ShareModal from '$modals/ShareModal.svelte';
    import { Separator } from "$components/ui/separator";

    export let event: NDKEvent;
    export let authorUrl: string | undefined = undefined;

    const share = $ndk.storeSubscribe([
        { kinds: [NDKKind.GenericRepost], ...event.filter() },
    ])

    onDestroy(() => {
        share.unsubscribe();
    });

    const sharedByCurrentUser = derived([share, currentUser], ([$share, $currentUser]) => {
        return $share.find((bookmark) => bookmark.pubkey === $currentUser?.pubkey);
    });

    const users = derived(share, ($share) => $share.map((bookmark) => bookmark.pubkey));

    async function repost() {
        event.repost(true);
        toast.success('Reposted');
    }

    function openShare() {
        openModal(ShareModal, { event });
    }
</script>

<HoverCard.Root openDelay={0} closeDelay={250}>
    <HoverCard.Trigger>
        <ButtonWithCount
            count={$share.length}
            class="
                gap-3 hover:bg-green-500/20 group rounded-full text-muted-foreground
            "
            on:click={repost}
        >
            <ArrowsClockwise size={20} weight="bold" class="
                transition-all duration-100 group-hover:text-green-500
                { !!$sharedByCurrentUser ? 'text-green-500' : '' }
            " />
        </ButtonWithCount>
    </HoverCard.Trigger>
    <HoverCard.Content class="p-0 w-fit flex flex-col">
        <Button variant="ghost" class="items-start justify-start" on:click={repost}>
            <ArrowsClockwise size={20} weight="bold" class="mr-3" />
            <div class="flex flex-col items-start gap-0 5">
                <span class="text-muted-foreground">
                    Repost
                    {#if !!$sharedByCurrentUser}
                        again
                    {/if}
                </span>
            </div>
        </Button>

        <Button variant="ghost" class="items-start justify-start" on:click={openShare}>
            <Export size={20} weight="bold" class="mr-3" />
            <span class="text-muted-foreground">Share with comment...</span>
        </Button>

        {#if $share.length > 0}
            <Separator />
        
            <Button variant="ghost" class="items-start justify-start" href={getEventUrl(event, authorUrl, 'shares')}>
                <Eye size={20} weight="bold" class="mr-3" />
                <span class="text-muted-foreground mr-6">View shares</span>
                <ReplyAvatars users={$users} size="xs" />
            </Button>
        {/if}
    </HoverCard.Content>
</HoverCard.Root>