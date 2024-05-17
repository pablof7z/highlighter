<script lang="ts">
	import ModalShell from "$components/ModalShell.svelte";
	import NewPost from "$components/Feed/NewPost/NewPost.svelte";
	import { NDKEvent, NDKKind, NDKTag, NDKUserProfile } from "@nostr-dev-kit/ndk";
    import { closeModal } from "$utils/modal";
	import { Name, ndk } from "@kind0/ui-common";
	import EventWrapper from "$components/Feed/EventWrapper.svelte";
	import { appMobileView } from "$stores/app";
	import { Button, Link, Toolbar } from "konsta/svelte";
	import UserProfile from "$components/User/UserProfile.svelte";
	import { UserProfileType } from "../../app";

    export let replyTo: NDKEvent | undefined = undefined;
    export let tags: NDKTag[] = [];
    export let placeholder = "What is happening?!";

    if (replyTo) {
        const e = new NDKEvent($ndk);
        e.tag(replyTo, "reply");
        tags = [...tags, ...e.tags]
    }
    
    let publishing = false;

    let forcePublish = false;
    let content: string;

    function cancel() {
        closeModal();
    }

    let replyToUserProfile: UserProfileType | null;

    if (replyTo) {
        placeholder = "Post your reply";
    }
</script>

<ModalShell
    color="glassy" class="w-full sm:max-w-2xl sm:!p-2 max-sm:h-full {publishing ? "!bg-transparent" : ""}"
>
    {#if $appMobileView}
        <Toolbar top>
            <div class="left">
                <Link onClick={(cancel)}>
                    Cancel
                </Link>
            </div>

            {#if $$slots.buttonsBar}
                <slot name="buttonsBar" />
            {/if}
            
            <div class="right">
                <Button rounded large class="px-6" onClick={() => forcePublish = true} disabled={content?.length === 0}>
                    {#if publishing}
                        Publishing...
                    {:else}
                        Post
                    {/if}
                </Button>
            </div>
        </Toolbar>
        {/if}

    {#if publishing}
        <div class="loading loading-lg loading-dots"></div>
    {/if}

    {#if replyTo}
        <EventWrapper
            ndk={$ndk}
            event={replyTo}
            class="text-white text-xs max-sm:max-h-[30dvh] overflow-y-auto"
            contentClass="!text-xs"
            compact={true}
            skipFooter={true}
            skipReply={true}
            skipZaps={true}
            skipSwipe={true}
            expandReplies={false}
            exppandThread={false}
        />
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
            bind:content
            autofocus={false}
            extraTags={tags}
            bind:publishing
            on:publish={() => {
                closeModal();
            }}
            on:cancel={closeModal}
        />
    </div>
</ModalShell>