<script lang="ts">
	import { Eye } from 'phosphor-svelte';
	import ZapModal from './../../../modals/ZapModal.svelte';
	import { openModal } from '$utils/modal';
	import { getTotalZapAmount } from '$utils/zaps';
	import { Lightning } from 'phosphor-svelte';
	import ButtonWithCount from '$components/buttons/ButtonWithCount.svelte';
	import { NDKEvent } from '@nostr-dev-kit/ndk';
	import { onDestroy } from 'svelte';
    import { nicelyFormattedMilliSatNumber } from '$lib/utils';
    import * as HoverCard from "$lib/components/ui/hover-card";
	import ReplyAvatars from '$components/Feed/ReplyAvatars.svelte';
	import { derived } from 'svelte/store';
	import { Button } from '$components/ui/button';
	import { getEventUrl } from '$utils/url';
    import Zap from "$components/Events/Zaps/Zap.svelte";
	import Separator from '$components/ui/separator/separator.svelte';

    export let event: NDKEvent;
    export let zapped = false;
    export let authorUrl: string | undefined = undefined;
    let _zapped = zapped;

    // after zapping, the button will be green for 2 seconds
    $: if (_zapped) {
        _zapped = false;
        setTimeout(() => zapped = false, 2000);
    }

    const zaps = getTotalZapAmount(event);
    const events = zaps.events;
    const users = derived(events, $events => $events.map(event => event.pubkey));

    onDestroy(() => {
        zaps.unsubscribe();
    });

    let zap: string;

    $: zap = nicelyFormattedMilliSatNumber($zaps);

    function clicked() {
        openModal(ZapModal, { event });
    }

    let closeDelay = 100;
</script>

<HoverCard.Root openDelay={0} {closeDelay}>
    <HoverCard.Trigger>
        <ButtonWithCount
            count={zap}
            class="gap-3 hover:bg-gold/20 rounded-full group"
            on:click={clicked}
        >
            <Lightning size={20} weight="fill" class="transition-all duration-100 group-hover:text-gold" />
        </ButtonWithCount>
    </HoverCard.Trigger>

    <HoverCard.Content class="p-0 w-fit flex flex-col">
        <div class="p-4">
            <Zap
                target={event}
                skipButton
                skipSplits
                buttonClass="button"
            />
        </div>

        <Separator />
        
        <Button variant="ghost" class="flex items-center justify-start" href={getEventUrl(event, authorUrl, 'shares')}>
            <Eye size={20} weight="bold" class="mr-3" />
            <span class="text-muted-foreground mr-6">View zaps</span>
            <ReplyAvatars users={$users} size="xs" />
        </Button>
    </HoverCard.Content>
    
</HoverCard.Root>
