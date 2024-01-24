<script lang="ts">
	import AvatarWithName from "$components/User/AvatarWithName.svelte";
	import { RelativeTime, user } from "@kind0/ui-common";
	import type { NDKEvent } from "@nostr-dev-kit/ndk";
	import type { UserProfileType } from "../../../app";
	import { urlSuffixFromEvent } from "$utils/url";
	import UserProfile from "$components/User/UserProfile.svelte";
	import SaveForLaterButton from "$components/SaveForLaterButton.svelte";
    import { debugMode } from "$stores/session";
	import Bug from "phosphor-svelte/lib/Bug";

    export let event: NDKEvent;
    export let description: string | undefined = undefined;
    export let title: string | undefined = "Untitled";
    export let durationTag: string | undefined = undefined;
    export let image: string | undefined = undefined;
    export let grid = false;
    export let skipAuthor = false;
    export let skipLink = false;
    export let size: "small" | "normal" = "normal";

    const author = event.author;

    let userProfile: UserProfileType;
    let authorUrl: string;

    let suffixUrl = skipLink ? "#" : urlSuffixFromEvent(event);
    let href: string;

    $: if (!image) { image = userProfile?.image || userProfile?.banner }
    $: href = `${authorUrl}/${suffixUrl}`;

    let timestamp = (event?.published_at || event?.created_at)*1000;

    function clicked(e: MouseEvent) {
        // if a button was clicked, don't trigger the link
        console.log("clicked", e.target);
        debugger
        if ((e.target as HTMLElement).closest("button")) {
            e.preventDefault();
        }
    }
</script>

<a class="
    flex gap-2 flex-nowrap relative group
    {grid ? "sm:flex-col" : "flex-row sm:gap-6"}

" {href}>
    {#if !grid && $user}
        <!-- Create a div so that clicks on the save button don't trigger the link -->
        <SaveForLaterButton {event} class="absolute top-0 right-0" />
    {/if}
    <a {href} class="
        flex-none overflow-hidden sm:rounded-2xl relative
        {grid ? "sm:w-full h-[100px] sm:h-[180px]" : (
            (size === "small" && "sm:w-20 sm:h-fit") ||
            (size === "normal" && "sm:w-64 sm:h-36")
        )}
    ">
        {#if image}
            <img src={image} alt={title} class="w-full object-cover" />
        {:else}
            <div class="bg-gray-200" />
        {/if}
        {#if durationTag && size === "normal"}
            <div class="max-sm:hidden self-stretch text-white text-xs font-medium absolute top-3 right-3 bg-base-300/80 py-1 px-2 rounded-lg">
                {durationTag}
            </div>
        {/if}
    </a>

    <div class="
        w-5/6 sm:w-full grow shrink basis-0 flex-col justify-start items-start md:gap-1 inline-flex md:max-h-36 max-sm:px-3 h-full
        {grid ? "sm:flex-col-reverse" : ""}
    ">
        {#if !skipAuthor}
            <!-- Pushes the content up (since this is a flex-col-reverse) -->
            <div class="sm:flex-grow" class:hidden={!grid}></div>
            <div class="self-stretch justify-between items-center inline-flex leading-5">
                <div class="
                    gap-3 flex w-full  whitespace-nowrap truncate items-end
                    {grid ? "" : "sm:mb-2"}
                ">
                    <AvatarWithName
                        user={author}
                        spacing="gap-2"
                        avatarSize="tiny"
                        avatarType="square"
                        avatarClass="max-sm:hidden"
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
        <a {href} class="
            self-stretch text-white font-semibold leading-relaxed
            {grid ? "" : "sm:text-xl"}
        ">
            {title}
        </a>
        {#if description}
            <a {href} class="self-stretch text-neutral-500 text-sm font-normal overflow-y-clip
                {grid ? "sm:hidden max-h-[1.5rem]" : ""}
            ">
                {description}
            </a>
        {/if}
    </div>

    {#if $debugMode}
        <button on:click={() => { console.log(event.rawEvent())} }>
            <Bug />
        </button>
    {/if}
</a>
