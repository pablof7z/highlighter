<script lang="ts">
	import AvatarWithName from "$components/User/AvatarWithName.svelte";
	import { getSummary } from "$utils/article";
	import { RelativeTime, ndk } from "@kind0/ui-common";
	import type { NDKArticle, NDKEvent } from "@nostr-dev-kit/ndk";
	import type { UserProfileType } from "../../../app";
	import { urlSuffixFromEvent } from "$utils/url";
	import UserProfile from "$components/User/UserProfile.svelte";

    export let event: NDKEvent;
    export let description: string | undefined = undefined;
    export let title: string | undefined = undefined;
    export let durationTag: string | undefined = undefined;
    export let image: string | undefined = undefined;
    export let grid = false;
    export let skipAuthor = false;
    export let skipLink = false;

    const author = event.author;

    let userProfile: UserProfileType;
    let authorUrl: string;

    let suffixUrl = skipLink ? "#" : urlSuffixFromEvent(event);
    let href: string;

    $: if (!image) { image = userProfile?.image || userProfile?.banner }
    $: href = `${authorUrl}/${suffixUrl}`;

    let timestamp = event?.published_at || event?.created_at;
</script>

<a {href} class="
    flex gap-2 flex-nowrap
    {grid ? "sm:flex-col" : "flex-row sm:gap-6"}
">
    <div class="
        w-1/4 flex-none overflow-hidden sm:rounded-2xl relative
        {grid ? "sm:w-full h-[100px] sm:h-[180px]" : "sm:w-64 sm:h-36"}
    ">
        {#if image}
            <img src={image} alt={title} class="w-full object-cover" />
        {:else}
            <div class="bg-gray-200" />
        {/if}
        {#if durationTag}
            <div class="max-sm:hidden self-stretch text-white text-xs font-medium absolute bottom-1 right-1 bg-base-300/80 py-1 px-2 rounded-lg">
                {durationTag}
            </div>
        {/if}
    </div>

    <div class="
        w-3/4 sm:w-full grow shrink basis-0 flex-col justify-start items-start md:gap-1 inline-flex md:max-h-36 max-sm:px-3 h-full
        {grid ? "sm:flex-col-reverse" : ""}
    ">
        {#if !skipAuthor}
            <div class="sm:flex-grow" class:hidden={!grid}></div>
            <div class="self-stretch justify-between items-center inline-flex leading-5">
                <div class="
                    gap-3 flex w-full  whitespace-nowrap truncate items-stretch
                    {grid ? "justify-between sm:items-start" : "justify-between sm:mb-2"}
                ">
                    <AvatarWithName
                        user={author}
                        spacing="gap-2"
                        avatarSize="tiny"
                        avatarType="square"
                        avatarClass="max-sm:hidden"
                        nameClass="max-sm:font-medium max-sm:text-sm"
                        bind:userProfile
                        bind:authorUrl
                    />

                    <RelativeTime {event} {timestamp} class="text-sm text-neutral-600" />
                </div>
            </div>
        {:else}
            <UserProfile bind:userProfile user={author} bind:authorUrl />
        {/if}
        <div class="
            self-stretch text-white font-semibold leading-relaxed
            {grid ? "" : "sm:text-xl"}
        ">
            {title}
        </div>
        {#if description}
            <div class="self-stretch text-neutral-500 text-sm font-normal overflow-y-clip
                {grid ? "sm:hidden max-h-[1.5rem]" : ""}
            ">
                {description}
            </div>
        {/if}
    </div>
</a>
