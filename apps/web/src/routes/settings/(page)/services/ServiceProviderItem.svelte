<script lang="ts">
	import { slide } from 'svelte/transition';
	import AvatarWithName from '$components/User/AvatarWithName.svelte';
	import { userFollows } from '$stores/session';
	import Avatar from '$components/User/Avatar.svelte';
import { ndk } from "$stores/ndk.js";
	import { NDKEvent, type Hexpubkey, type NDKUserProfile, NDKKind, type NostrEvent } from '@nostr-dev-kit/ndk';
    import { createEventDispatcher } from 'svelte';
	import { Button } from '$components/ui/button';

    export let kind: number;
    export let event: NDKEvent;
    export let profile: NDKUserProfile | null | undefined = undefined;
    export let forceDisplay = false;

    const dispatch = createEventDispatcher();

    if (!profile) {
        try {
            profile = JSON.parse(event.content);
            if (profile) {
                profile.image ??= profile.picture;
            }
        } catch {}
    }

    if (!profile) {
        event.author.fetchProfile().then((p) => {
            profile = p;
        });
    }

    let requests: Set<Hexpubkey> = new Set();
    let resultForPubkeys = new Set<Hexpubkey>();
    let resultForFollowedPubkeys = new Set<Hexpubkey>();
    let resultForNotFollowedPubkeys = new Set<Hexpubkey>();
    let results: Set<NDKEvent>;

    $ndk.fetchEvents([
        { kinds: [kind], "#p": [event.pubkey] }
    ], { groupable: true, groupableDelay: 150 }).then((reqEvents) => {
        reqEvents.forEach(reqEvent => {
            requests.add(reqEvent.pubkey);
        });
    });

    $ndk.fetchEvents({
        kinds: [kind+1000],
        authors: [event.pubkey],
    }, {
        groupable: true,
        groupableDelay: 150,
    }).then(events => {
        if (!resultForPubkeys) return;
        
        events.forEach(event => {
            const pTag = event.tagValue('p');

            if (pTag && $userFollows.has(pTag)) resultForFollowedPubkeys.add(pTag);
            else if (pTag) resultForNotFollowedPubkeys.add(pTag);
        });

        // get ten pubkeys, prefer followed ones
        let i = 0;
        for (const pubkey of resultForFollowedPubkeys) {
            if (i >= 10) break;
            resultForPubkeys.add(pubkey);
            i++;
        }
        if (resultForPubkeys.size < 10) {
            for (const pubkey of resultForNotFollowedPubkeys) {
                if (i >= 10) break;
                resultForPubkeys.add(pubkey);
                i++;
            }
        }

        results = events;
    });

    let emittedReady = false;

    $: if (profile && results && results.size > 0) {
        emittedReady = true;
        dispatch('ready');
    }

    async function select() {
        const apprec = new NDKEvent($ndk, {
            kind: NDKKind.AppRecommendation,
            tags: [
                ["d", kind.toString()],
            ],
        } as NostrEvent);
        apprec.tag(event);
        await apprec.publish();
    }
</script>

{#if emittedReady || forceDisplay}
    <div class="flex flex-col gap-4 py-4 border-b border-border px-4" transition:slide>
        <AvatarWithName
            userProfile={profile}
            class="!items-start"
            nameClass="font-medium text-foreground text-lg"
            spacing="gap-4"
        >
            <div class="text-sm text-neutral-500 text-left">
                {profile.about}
            </div>
        </AvatarWithName>

        {#if requests && requests.size > 0 || results.size > 0}
            <div class="flex flex-row justify-between w-full items-end pl-16">
                <Button variant="secondary" on:click={select}>
                    Select
                </Button>

                <div class="flex flex-col w-fit gap-1 self-end items-end">
                    <span class="text-neutral-500 text-sm tracking-loose font-semibold">
                        USED BY
                    </span>

                    <div class="flex flex-row -space-x-4 rtl:space-x-reverse self-end items-center">

                        {#each Array.from(requests) as userPubkey}
                            <Avatar
                                pubkey={userPubkey}
                                size="small"
                                type="square"
                            />
                        {/each}
                        {#each Array.from(resultForPubkeys) as pubkey}
                            <Avatar
                                {pubkey}
                                size="small"
                                type="square"
                            />
                        {/each}
                    </div>
                </div>
            </div>
        {/if}
    </div>
{/if}