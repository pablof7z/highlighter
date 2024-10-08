<script lang="ts">
	import AvatarWithName from "$components/User/AvatarWithName.svelte";
	import { NDKArticle, NDKKind, type NDKEvent } from "@nostr-dev-kit/ndk";
	import type { UserProfileType } from "../../../app";
	import { urlFromEvent } from "$utils/url";
	import UserProfile from "$components/User/UserProfile.svelte";
	import DurationTag from "$components/DurationTag.svelte";
	import TopZap from "./TopZap.svelte";
	import EventTags from "./EventTags.svelte";
	import RelativeTime from "$components/PageElements/RelativeTime.svelte";
	import currentUser from "$stores/currentUser";
	import { articleKinds } from "$utils/event";

    export let event: NDKEvent;

    if (articleKinds.includes(event.kind) && !(event instanceof NDKArticle)) {
        event = NDKArticle.from(event);
    }
    
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

    const isHrefExplicit = !!href;

    $: if (!image && userProfile) { image = userProfile.image || userProfile.banner }

    $: title ??= "Untitled";

    const author = event.author;

    let userProfile: UserProfileType;
    let authorUrl: string = `/${author.npub}`;

    $: if (!image && useProfileAsDefaultImage) { image = userProfile?.image || userProfile?.banner }
    $: if (!isHrefExplicit && !skipLink) {
        href = urlFromEvent(event, authorUrl);
    }

    let timestamp = (event?.published_at || event?.created_at)*1000;
</script>

<a class="
    flex gap-2 flex-nowrap relative group w-full overflow-clip
    {$$props.class??""}
    {grid ? "flex-col sm:flex-col" : "max-sm:flex-col flex-row sm:gap-6"}

" {href} class:!cursor-default={skipLink}>
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
                <div class="bg-foreground/10 w-full overflow-clip h-full">
                    <div class="text-lg sm:text-3xl font-semibold gradient-text whitespace-normal w-full p-2 sm:p-6 leading-relaxed flex h-full items-end">
                        {title}
                        {durationTag}
                    </div>
                </div>
            {/if}
        </div>
        {#if durationTag}
            <DurationTag value={durationTag} class="absolute top-3 right-3 z-10" />
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
            self-stretch text-foreground font-semibold leading-relaxed
            {grid ? "max-sm:text-xl max-sm:font-[InterDisplay]" : "sm:text-xl"}
        ">
            {title}
        </a>
        {#if description}
            <a dir="auto" {href} class="self-stretch w-full text-neutral-500 text-sm font-normal basis-0 grow overflow-clip
                {grid ? "" : ""}
            ">
                {description}
            </a>
        {:else}
            <div class="grow"></div>
        {/if}
        <slot />

        {#if !grid}
            <EventTags {event} />
            <TopZap {event} class="text-xs" />
        {/if}
    </div>
</a>