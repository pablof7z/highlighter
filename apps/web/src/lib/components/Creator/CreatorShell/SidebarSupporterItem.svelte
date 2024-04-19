<script lang="ts">
	import { NDKEvent, NDKKind, NDKSubscriptionReceipt, NostrEvent } from '@nostr-dev-kit/ndk';
	import { Hexpubkey } from '@nostr-dev-kit/ndk';
    import UserProfile from "$components/User/UserProfile.svelte";
	import { ndk, Avatar, Name, RelativeTime, user as currentUser, Textarea } from "@kind0/ui-common";
	import { onDestroy } from 'svelte';
	import { EventContent } from '@nostr-dev-kit/ndk-svelte-components';
	import { getDefaultRelaySet } from '$utils/ndk';
	import AvatarWithName from '$components/User/AvatarWithName.svelte';

    export let creatorPubkey: Hexpubkey;
    export let pubkey: Hexpubkey;
    export let position: number;
    export let tierNames: Record<string, string> = {};
    export let tier: string;
    export let receipt: NDKSubscriptionReceipt;

    const substart = $ndk.storeSubscribe(
        { kinds: [NDKKind.Subscribe], "authors": [pubkey], "#p": [creatorPubkey] },
    );

    const supporterNote = $ndk.storeSubscribe(
        { kinds: [ NDKKind.GroupReply ], "#h": [creatorPubkey], "authors": [pubkey], "#e": [receipt.id] },
    );

    onDestroy(() => {
        substart.unsubscribe();
        supporterNote.unsubscribe();
    });

    let showForm = false;
    let note = "";

    async function publish() {
        const e = new NDKEvent($ndk, {
            content: note,
            kind: NDKKind.GroupReply,
            tags: [
                [ "h", creatorPubkey ],
            ]
        } as NostrEvent);
        e.tag(receipt);
        await e.publish(getDefaultRelaySet());
        showForm = false;
    }
</script>

<UserProfile {pubkey} let:userProfile let:fetching let:authorUrl>
    <a href={authorUrl} class="rounded-box flex flex-col gap-2 items-start justify-between discussion-item">
        <div class="flex flex-row gap-2 justify-stretch items-start grow w-full">
            <Avatar {pubkey} {userProfile} {fetching} type="square" size="small" />
            <div class="flex flex-col grow">
                <Name  npubMaxLength={12} {pubkey} {userProfile} {fetching} class="text-white truncate grow" />
                {#if $substart.length > 0}
                    <div class="text-xs text-neutral-500">
                        Since
                        <RelativeTime event={$substart[0]} />
                    </div>
                {/if}
            </div>
            <div class="flex flex-col gap-0 items-center justify-center flex-none">
                <div class="text-xl font-black text-white opacity-80 flex flex-row items-end">
                    <span class="opacity-50 font-normal">#</span>{position+1}
                </div>
            </div>
        </div>
        <div class="flex flex-col items-start w-full">
            {#if $supporterNote.length > 0}
                <EventContent event={$supporterNote[0]} ndk={$ndk} class="text-base text-neutral-300" />
            {:else if $currentUser?.pubkey === pubkey && !showForm}
                <button class="self-start button bg-white/10 text-white/60 mt-4 px-4 py-3 truncate max-w-[20rem]" on:click|stopImmediatePropagation|preventDefault={() => showForm = !showForm}>
                    Click to add a note
                </button>
            {:else if showForm}
                <!-- svelte-ignore a11y-click-events-have-key-events -->
                <!-- svelte-ignore a11y-no-static-element-interactions -->
                <div class="flex flex-col gap-2 w-full" on:click|stopImmediatePropagation|preventDefault={() => {}}>
                    <Textarea bind:value={note} class="textarea w-full" />
                    <div class="flex flex-row gap-4 items-end">
                        <button class="button" on:click={publish}>
                            Publish
                        </button>
                        <button on:click={() => showForm = false}>
                            Cancel
                        </button>
                    </div>
                </div>
            {/if}
        </div>
    </a>
</UserProfile>
