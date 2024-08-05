<script lang="ts">
	import NewPost from "$components/Feed/NewPost/NewPost.svelte";
	import { NDKEvent, NDKKind, NDKTag, dvmSchedule } from "@nostr-dev-kit/ndk";
    import { closeModal, openModal } from "$utils/modal";
	import EventWrapper from "$components/Feed/EventWrapper.svelte";
	import { appMobileView } from "$stores/app";
	import UserProfile from "$components/User/UserProfile.svelte";
	import { NavigationOption, UserProfileType } from "../../app";
	import ItemLink from "$components/Events/ItemLink.svelte";
	import { goto } from "$app/navigation";
	import { ndk } from "$stores/ndk";
	import Name from "$components/User/Name.svelte";
	import { Timer } from "phosphor-svelte";
	import ScheduleModal from "./ScheduleModal.svelte";
	import { dvmScheduleEvent } from "$lib/dvm";
	import { replyKind } from "$utils/event";

    export let replyTo: NDKEvent | undefined = undefined;
    export let tags: NDKTag[] = [];
    export let placeholder = "What is happening?!";
    export let title: string | undefined;
    export let wrapperClass: string = "";

    $: title = $appMobileView ? undefined : "New Post";

    export let kind: NDKKind | undefined = undefined;
    
    if (!kind) {
        if (replyTo) {
            kind = replyKind(replyTo);
        } else {
            kind = NDKKind.Text;
        }
    }
    
    if (replyTo) {
        const e = new NDKEvent($ndk);
        e.tag(replyTo, "reply");
        tags = [...tags, ...e.tags]

        title = "Reply";
    }
    
    let publishing = false;

    let forcePublish = false;
    let forceGenerateEvent = false;
    let content: string;

    let replyToUserProfile: UserProfileType | null;

    if (replyTo) {
        placeholder = "Post your reply";
    }

    export let actionButtons: NavigationOption[] = [];

    let event: NDKEvent;

    if (replyTo) {
        const e = new NDKEvent($ndk);
        e.tag(replyTo, "reply");
        tags = [...tags, ...e.tags]
    }
    
    function schedule() {
        forceGenerateEvent = true;
        openModal(ScheduleModal, {
            title: 'Schedule Post',
            onSchedule: async (timestamp: number) => {
                event.created_at = Math.floor(timestamp/1000);
                await event.sign();
                dvmScheduleEvent(event);
                setTimeout(() => {
                    closeModal(ScheduleModal);
                    closeModal();
                }, 1500);
            }
        })
    }

    $: {
        actionButtons = [
            { icon: Timer, fn: schedule },
            { name: publishing ? "Publishing" : "Publish", fn: () => { forcePublish = true; }, buttonProps: { variant: 'default', class: 'px-6' } }
        ];
    }

    $: wrapperClass = `w-full sm:max-w-3xl max-sm:h-full ${publishing ? "!bg-transparent" : ""}`;
</script>

{#if replyTo}
    {#if [NDKKind.Text, NDKKind.GroupNote, NDKKind.GroupReply].includes(replyTo.kind)}
        <EventWrapper
            ndk={$ndk}
            event={replyTo}
            class="text-foreground text-xs max-sm:max-h-[30dvh] overflow-y-auto border border-border rounded bg-secondary/50"
            contentClass="!text-xs"
            compact={true}
            showReply={false}
            skipFooter={true}
            skipReply={true}
            skipZaps={true}
            skipSwipe={true}
            expandReplies={false}
            exppandThread={false}
        />
    {:else}
        <ItemLink event={replyTo} />
    {/if}
{/if}

<div class="w-full flex flex-col max-sm:min-h-[80dvh]">
    {#if replyTo}
        <UserProfile user={replyTo.author} bind:userProfile={replyToUserProfile}>
            <div class="text-xs translate-y-2 mt-2 mb-4 text-muted-foreground">
                Replying to
                <Name user={replyTo.author} userProfile={replyToUserProfile} />
            </div>
        </UserProfile>
    {/if}

    <NewPost
        {kind}
        {placeholder}
        editorClass="text-foreground min-h-[7rem] h-full grow text-xl"
        skipAvatar={true}
        collapsed={false}
        {forcePublish}
        {forceGenerateEvent}
        bind:content
        bind:event
        autofocus={true}
        extraTags={tags}
        bind:publishing
        skipButtons
        skipFadeMode
        on:publish={(e) => {
            const event = e.detail;
            goto(`/a/${event.encode()}`);
            closeModal();
        }}
    >
    </NewPost>
</div>

<div class="hidden w-full sm:max-w-3xl max-sm:h-full"></div>