<script lang="ts">
	import AvatarWithName from "$components/User/AvatarWithName.svelte";
	import { getSummary } from "$utils/article";
	import { RelativeTime, ndk } from "@kind0/ui-common";
	import type { NDKVideo } from "@nostr-dev-kit/ndk";
	import type { UserProfileType } from "../../../app";
	import { urlSuffixFromEvent } from "$utils/url";
	import UserProfile from "$components/User/UserProfile.svelte";

    export let video: NDKVideo;
    export let skipAuthor = false;

    let userProfile: UserProfileType;
    let authorUrl: string;

    const summary = video.summary || getSummary(video);

    let image = video.thumbnail;
    let suffixUrl = urlSuffixFromEvent(video);
    let href: string;

    $: if (!image) { image = userProfile?.image || userProfile?.banner }
    $: href = `${authorUrl}/${suffixUrl}`;
</script>

<a {href} class="flex flex-col md:flex-row gap-2 sm:gap-6">
    <div class="w-screen max-h-48 sm:w-64 sm:h-36 flex-none overflow-hidden sm:rounded-2xl">
        {#if image}
            <img src={image} alt={video.title} class="w-full object-cover" />
        {:else}
            <div class="bg-gray-200" />
        {/if}
    </div>

    <div class="grow shrink basis-0 flex-col justify-start items-start gap-2 inline-flex h-full md:max-h-36 max-sm:px-3 overflow-clip">
        {#if !skipAuthor}
            <div class="self-stretch justify-between items-center inline-flex leading-5">
                <div class="justify-start items-center gap-3 flex">
                    <AvatarWithName
                        user={video.author}
                        spacing="gap-4"
                        avatarSize="small"
                        bind:userProfile
                        bind:authorUrl
                    />

                    <RelativeTime event={video} class="text-sm opacity-60" />
                </div>
            </div>
        {:else}
            <UserProfile bind:userProfile user={video.author} bind:authorUrl />
        {/if}
        <div class="self-stretch text-neutral-200 text-xl font-semibold leading-relaxed">
            {video.title}
        </div>
        <div class="self-stretch text-neutral-500 text-sm font-normal overflow-y-clip">
            {summary}
        </div>
    </div>
</a>
