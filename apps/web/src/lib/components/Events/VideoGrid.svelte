<script lang="ts">
	import { Avatar, Name } from "@kind0/ui-common";
	import type { NDKvideo } from "@nostr-dev-kit/ndk";
    import UserProfile from "$components/User/UserProfile.svelte";
    import { prettifyNip05 } from "@nostr-dev-kit/ndk-svelte-components";
    import type { UserProfileType } from "../../../app";
	import { niceDuration } from "$utils/video";

    export let video: NDKvideo;
    export let size: "small" | "large" = "small";
    export let skipAuthor: boolean = false;
    export let skipLink = false;

    const suffixUrl = video.tagValue("d") || video.id;

    const user = video.author;
    let userProfile: UserProfileType | undefined = undefined;

    let authorId = user.npub;
    let videoLink = `/${user.npub}/${suffixUrl}`;

    $: authorId = userProfile?.nip05 ? prettifyNip05(userProfile.nip05, 999999) : user.npub;
    $: videoLink = skipLink ? "" : `/${authorId}/${suffixUrl}`;

    const defaultUrl = "https://cdn.satellite.earth/01a8a5f5162a90fd7e6d3af6bc86d975e08a98f1852864c8ae7d8ba547bad669.png";
</script>

<UserProfile {user} bind:userProfile let:fetching>
    <a href={videoLink} class="flex flex-col items-start gap-4 h-full {size}">
        <div class="relative max-sm:{size} !w-full h-fit flex-none rounded-xl">
            <img class="{size} !w-full max-sm:!max-h-[1800px] max-sm:!h-fit object-cover bg-gradient-to-r from-base-300/80 to-base-300 border-none object-top flex-none rounded-xl" src={video.thumbnail??defaultUrl} />
            {#if video.duration}
                <div class="absolute bottom-0 right-0 flex flex-row items-center justify-center gap-2 p-2">
                    <div class="bg-base-100/70 rounded-lg px-3 py-1 text-white text-xs font-medium">
                        {niceDuration(video.duration)}
                    </div>
                </div>
            {/if}
        </div>
        <div class="self-stretch justify-start items-start gap-4 inline-flex">
            {#if !skipAuthor}
                <a href="/{authorId}" class="justify-start flex-none items-start gap-4 flex">
                    <Avatar {user} {userProfile} {fetching} class="w-11 h-11 rounded-full" />
                </a>
            {/if}
            <div class="w-full shrink flex-col justify-start items-start gap-2 flex">
                <div class="self-stretch text-white text-[15px] font-medium max-h-10 overflow-y-clip">
                    {video.title}
                </div>
                <div class="flex self-stretch h-[38px] flex-row sm:flex-col justify-start items-center
                    gap-8 sm:gap-1
                ">
                    {#if !skipAuthor}
                        <a href="/{authorId}" class="self-stretch text-white text-opacity-60 text-sm font-medium">
                            <Name {user} {userProfile} {fetching} />
                        </a>
                    {/if}
                </div>
            </div>
        </div>
    </a>
</UserProfile>

<style lang="postcss">
    a.small {
        width: 321px;
    }

    img.small {
        width: 321px;
        height: 180px;
    }

    .large {
        @apply w-[346px] h-[180px];
    }

    a {
        @apply transition-all duration-300 ease-in-out;
    }

    a:hover {
        transform: scale(1.02);
    }
</style>