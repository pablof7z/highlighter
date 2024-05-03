<script lang="ts">
	import AvatarWithName from "$components/User/AvatarWithName.svelte";
	import { RelativeTime, user } from "@kind0/ui-common";
	import { NDKArticle, type NDKEvent } from "@nostr-dev-kit/ndk";
	import type { UserProfileType } from "../../../app";
	import { urlSuffixFromEvent } from "$utils/url";
	import UserProfile from "$components/User/UserProfile.svelte";
	import SaveForLaterButton from "$components/SaveForLaterButton.svelte";
    import { debugMode } from "$stores/session";
	import Bug from "phosphor-svelte/lib/Bug";
	import DurationTag from "$components/DurationTag.svelte";
	import TopZap from "./TopZap.svelte";

    export let event: NDKEvent;
    export let description: string | undefined = (event instanceof NDKArticle) ? event.summary : undefined;
    export let title: string | undefined = (event instanceof NDKArticle) ? event.title : "Untitled";
    export let durationTag: string | undefined = undefined;
    export let image: string | undefined = (event instanceof NDKArticle) ? event.image : "Untitled";
    export let grid = false;
    export let skipAuthor = false;
    export let skipLink = false;
    export let size: "small" | "normal" = "normal";
    export let useProfileAsDefaultImage = true;
    export let href: string | undefined = undefined;

    const hrefSet = !!href;

    $: if (!image && userProfile) { image = userProfile.image || userProfile.banner }

    $: title ??= "Untitled";

    const author = event.author;

    let userProfile: UserProfileType;
    let authorUrl: string = `/${author.npub}`;

    let suffixUrl = skipLink ? "#" : urlSuffixFromEvent(event);

    $: if (!image && useProfileAsDefaultImage) { image = userProfile?.image || userProfile?.banner }
    $: if (!hrefSet && !skipLink) {
        href = `${authorUrl}/${suffixUrl}`;
    }

    let timestamp = (event?.published_at || event?.created_at)*1000;
</script>

<a class="
    flex gap-2 flex-nowrap relative group w-full overflow-clip
    {grid ? "flex-col sm:flex-col" : "max-sm:flex-col flex-row sm:gap-6"}

" {href} class:!cursor-default={skipLink}>
    {#if !grid && $user && event.sig}
        <!-- Create a div so that clicks on the save button don't trigger the link -->
        <SaveForLaterButton {event} class="absolute top-0 right-2" />
    {/if}
    <a {href} class="
        flex-none overflow-hidden relative
        {grid ? "sm:w-full h-[30vh] sm:h-[180px]" : (
            (size === "small" && "sm:w-20 sm:h-fit") ||
            (size === "normal" && "sm:w-64 sm:h-44")
        )}
    ">
        <div class="w-full max-sm:min-h-[35vh] sm:h-full relative flex flex-row items-center justify-center" style={`
        `}>
            {#if image}
                <img src={image} alt={title} class="w-full h-full absolute top-0 left-0 z-[1] backdrop-blur-xl" style="filter: blur(50px)" />
                <img src={image} alt={title} class="object-fit sm:rounded max-sm:max-h-[35vh] absolute z-[5]" />
            {:else}
                <div class="bg-base-200 w-full overflow-clip h-full">
                    <div class="text-lg sm:text-3xl font-semibold gradient-text whitespace-normal w-full p-2 sm:p-6 leading-relaxed flex h-full items-end">
                        {title}
                    </div>
                </div>
            {/if}
        </div>
        {#if durationTag && size === "normal"}
            <DurationTag value={durationTag} class="absolute top-3 right-3" />
        {/if}

        {#if grid}
            <div class="absolute bottom-1 left-1 z-10 flex flex-row flex-nowrap gap-2">
                <TopZap {event} class="text-xs !pl-[4px] !py-1" />
            </div>
        {/if}
    </a>

    <div class="
        w-full grow flex-col justify-start items-start md:gap-1 inline-flex
        max-sm:px-2 overflow-clip
        {grid ? "max-sm:items-stretch" : ""}
    ">
        {#if !skipAuthor}
            <!-- Pushes the content up (since this is a flex-col-reverse) -->
            <div class="flex-grow" class:hidden={!grid}></div>
            <div class="self-stretch inline-flex leading-5">
                <div class="
                    gap-3 flex w-full whitespace-nowrap truncate items-end justify-between items-center
                    {grid ? "" : "sm:mb-2"}
                ">
                    <AvatarWithName
                        user={author}
                        spacing="gap-2"
                        avatarSize="tiny"
                        avatarType="square"
                        nameClass="font-normal text-sm"
                        bind:userProfile
                        bind:authorUrl
                    />

                    <RelativeTime {event} {timestamp} class="text-sm text-neutral-600" />
                </div>
            </div>
        {:else}
            <UserProfile bind:userProfile user={author} bind:authorUrl />
        {/if}
        <a dir="auto" {href} class="
            self-stretch text-base-100-content font-semibold leading-relaxed
            {grid ? "max-sm:text-xl max-sm:font-[InterDisplay]" : "sm:text-xl"}
        ">
            {title}
        </a>
        {#if description}
            <a dir="auto" {href} class="self-stretch max-h-[1.5rem] w-full text-neutral-500 text-sm font-normal basis-0 grow overflow-clip
                {grid ? "" : ""}
            ">
                {description}
            </a>
        {/if}
        <slot />

        {#if !grid}
            <TopZap {event} class="text-xs" />
        {/if}
    </div>

    {#if $debugMode}
        <button on:click={() => { console.log(event.rawEvent())} }>
            <Bug />
        </button>
    {/if}
</a>