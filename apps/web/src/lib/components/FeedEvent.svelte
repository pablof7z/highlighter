<script lang="ts">
	import CommentIcon from "$icons/CommentIcon.svelte";
	import LikeIcon from "$icons/LikeIcon.svelte";
	import RepostIcon from "$icons/RepostIcon.svelte";
	import { requiredTiersFor } from "$lib/events/tiers";
	import { Avatar, Name, user } from "@kind0/ui-common";
    import type { NDKEvent, NDKTag, NDKUserProfile } from "@nostr-dev-kit/ndk";
	import { prettifyNip05 } from "@nostr-dev-kit/ndk-svelte-components";

    export let event: NDKEvent;
    export let skipAuthor: boolean = false;
    const author = event.author;

    export let suffixUrl: string;
    let userProfile: NDKUserProfile | null = null;

    let eventUrl = `/${author.npub}/${suffixUrl}`;

    author.fetchProfile().then(profile => {
        if (profile && profile.nip05) {
            userProfile = profile;
            const nip05 = prettifyNip05(profile.nip05, 999999);
            eventUrl = `/${nip05}/${suffixUrl}`;
        }
    });

    const tiers = requiredTiersFor(event);
    const includesFree = tiers.includes("Free");
</script>

<a href={eventUrl} class="flex flex-col gap-4 mt-4 pb-4 border-b border-neutral-800">
    <slot />

    <div class="w-full justify-between items-center inline-flex">
        {#if !skipAuthor}
            <div class="justify-start items-center gap-4 flex">
                <div class="w-12 h-12 relative">
                    <Avatar {userProfile} user={author} class="w-12 h-12 border border-white" />
                </div>
                <div class="flex flex-col gap-1 items-start">
                    <div class="text-white text-[15px] font-semibold">
                        <Name {userProfile} user={author} />
                    </div>

                    {#if event.pubkey === $user?.pubkey}
                    <div class="flex flex-row items-center gap-1 text-xs ">
                            {#if includesFree}
                                <div class="badge badge-neutral badge-sm">Free</div>
                            {:else}
                                {#each tiers as tier}
                                    <div class="badge badge-neutral badge-sm">{tier}</div>
                                {/each}
                            {/if}
                        </div>
                    {/if}
                </div>
            </div>
        {/if}
        <div class="grow shrink basis-0 flex-col justify-start items-end gap-1 inline-flex">
            <div class="justify-start items-start gap-3 inline-flex">
                <div class="w-7 h-7 relative">
                    <LikeIcon class="w-7 h-7" />
                </div>
                <div class="w-7 h-7 relative">
                    <CommentIcon class="w-7 h-7" />
                </div>
                <div class="w-7 h-7 relative">
                    <RepostIcon class="w-7 h-7" />
                </div>
            </div>
            <div class="self-stretch text-right text-white text-opacity-60 text-sm font-normal leading-[21px]">32 responses  108 boosts</div>
        </div>
    </div>
</a>