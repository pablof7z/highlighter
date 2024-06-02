<script lang="ts">
	import NewPost from "$components/Feed/NewPost/NewPost.svelte";
	import { NDKEvent, NDKKind, NDKTag, NDKUserProfile } from "@nostr-dev-kit/ndk";
    import { closeModal } from "$utils/modal";
	import { Name, ndk } from "@kind0/ui-common";
	import EventWrapper from "$components/Feed/EventWrapper.svelte";
	import { appMobileView } from "$stores/app";
	import UserProfile from "$components/User/UserProfile.svelte";
	import { NavigationOption, UserProfileType } from "../../app";
	import ItemLink from "$components/Events/ItemLink.svelte";
	import { goto } from "$app/navigation";

    export let replyTo: NDKEvent | undefined = undefined;
    export let tags: NDKTag[] = [];
    export let placeholder = "What is happening?!";
    export let title = "New Post";
    export let wrapperClass;
    
    if (replyTo) {
        const e = new NDKEvent($ndk);
        e.tag(replyTo, "reply");
        tags = [...tags, ...e.tags]

        title = "Reply";
    }
    
    let publishing = false;

    let forcePublish = false;
    let content: string;

    let replyToUserProfile: UserProfileType | null;

    if (replyTo) {
        placeholder = "Post your reply";
    }

    export let actionButtons: NavigationOption[] = [];

    $: {
        actionButtons = [
            { name: publishing ? "Publishing" : "Publish", fn: () => { forcePublish = true; }, class: "button main-modal-button" }
        ];

        if (!$appMobileView) {
            actionButtons.unshift({ name: "Cancel", fn: closeModal, class: ""});
        }
    }

    $: wrapperClass = `w-full sm:max-w-2xl max-sm:h-full ${publishing ? "!bg-transparent" : ""}`;
</script>

{#if replyTo}
    {#if replyTo.kind === 1}
        <EventWrapper
            ndk={$ndk}
            event={replyTo}
            class="text-white text-xs max-sm:max-h-[30dvh] overflow-y-auto"
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

<div class="w-full flex flex-col max-sm:min-h-[100dvh]">
    {#if replyTo}
        <UserProfile user={replyTo.author} bind:userProfile={replyToUserProfile}>
            <div class="text-xs translate-y-2">
                Replying to
                <Name user={replyTo.author} userProfile={replyToUserProfile} class="text-accent2" />
            </div>
        </UserProfile>
    {/if}

    <NewPost
        kind={NDKKind.Text}
        {placeholder}
        editorClass="text-white min-h-[7rem] h-full grow"
        skipAvatar={true}
        collapsed={false}
        {forcePublish}
        bind:content
        autofocus={true}
        extraTags={tags}
        bind:publishing
        skipButtons
        skipFadeMode
        on:publish={(e) => {
            const event = e.detail;
            goto(`/e/${event.encode()}`);
            closeModal();
        }}
    />
</div>