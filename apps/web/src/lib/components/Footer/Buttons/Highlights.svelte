<script lang="ts">
	import { goto } from '$app/navigation';
	import { getEventUrl } from '$utils/url';
	import LogoSmall from './../../../icons/LogoSmall.svelte';
    import { Separator } from "$components/ui/separator";
    import * as HoverCard from "$lib/components/ui/hover-card";
	import { ndk } from '$stores/ndk.js';
	import ButtonWithCount from '$components/buttons/ButtonWithCount.svelte';
	import { NDKEvent, NDKFilter, NDKHighlight, NDKKind } from '@nostr-dev-kit/ndk';
	import { onDestroy } from 'svelte';
    import { Button } from '$components/ui/button';
	import currentUser from '$stores/currentUser';
	import { Eye } from 'phosphor-svelte';
	import ReplyAvatars from '$components/Feed/ReplyAvatars.svelte';
	import { derived, Readable, Writable } from 'svelte/store';
	import { wot, wotFiltered, wotFilteredStore } from '$stores/wot';
	import Switch from '$components/ui/switch/switch.svelte';
	import { ArticleSettings } from '$components/Content/Article';

    export let event: NDKEvent;
    export let authorUrl: string | undefined = undefined;
    export let highlights: Readable<NDKHighlight[]>;
    export let settings: Writable<ArticleSettings>;

    const users = derived(highlights, ($highlights) => $highlights.map((hl) => hl.pubkey));

    const highlightsByUser = derived([highlights, currentUser], ([$highlights, $currentUser]) => {
        return $highlights.filter((hl) => hl.pubkey === $currentUser?.pubkey);
    });

    const highlightsByNetwork = wotFilteredStore(highlights);

    const highlightsOutOfNetwork = derived([highlights, currentUser], ([$highlights, $currentUser]) => {
        return $highlights.filter((hl) => {
            if (!$wot) return true;
            return hl.pubkey !== $currentUser?.pubkey && !$wot.has(hl.pubkey);
        });
    });

    function clicked() {
        goto(getEventUrl(event, undefined, 'highlights'));
    }
</script>

<HoverCard.Root openDelay={0} closeDelay={250}>
    <HoverCard.Trigger>
        <ButtonWithCount
            count={$highlights.length}
            class="gap-3 hover:bg-orange-500/20 group rounded-full text-muted-foreground"
            on:click={clicked}
        >
            <LogoSmall class="w-6 h-6 transition-all duration-100 group-hover:text-orange-500" />
        </ButtonWithCount>

    </HoverCard.Trigger>
    <HoverCard.Content class="p-0 w-fit flex flex-col">
        {#if $highlightsByUser.length > 0}
            <div class="text-muted-foreground flex flex-row justify-between w-full p-2 text-sm items-center px-4">
                My highlights
                <Switch bind:checked={$settings.highlights.byUser} />
            </div>
        {/if}
        
        {#if $highlightsByNetwork.length > 0}
            <div class="text-muted-foreground flex flex-row justify-between w-full p-2 text-sm items-center px-4">
                From my network
                <Switch bind:checked={$settings.highlights.byNetwork} />
            </div>
        {/if}

        {#if $highlightsOutOfNetwork.length > 0}
            <div class="text-muted-foreground flex flex-row justify-between w-full p-2 text-sm items-center px-4">
                Outside my network
                <Switch bind:checked={$settings.highlights.outOfNetwork} />
            </div>
        {/if}

        <Separator />

        <Button variant="ghost" class="items-start justify-start" href={getEventUrl(event, authorUrl, 'highlights')}>
            <Eye size={20} weight="bold" class="mr-3" />
            <span class="text-muted-foreground mr-6">View all highlights</span>
            <ReplyAvatars users={$users} size="xs" />
        </Button>
    </HoverCard.Content>
</HoverCard.Root>
