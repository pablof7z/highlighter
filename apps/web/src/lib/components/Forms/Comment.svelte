<script lang="ts">
	import { NDKEvent, NDKKind, type NDKTag, type NostrEvent } from "@nostr-dev-kit/ndk";
    import { Avatar, Name, Textarea, ndk, user } from "@kind0/ui-common";
    import UserProfile from "$components/User/UserProfile.svelte";
    import { userActiveSubscriptions } from "$stores/session";
    import { createEventDispatcher } from "svelte";
	import { getDefaultRelaySet } from "$utils/ndk";
    import { debugMode } from "$stores/session";

    const dispatch = createEventDispatcher();

    export let event: NDKEvent;
    export let narrowView = true;

    let content: string;

    let reply: NDKEvent | undefined;

    let debugView = true;

    function getCommentTags() {
        const tags: NDKTag[] = [];
        const rootTags = event.tags.filter(t => t[3] === "root");
        const hasRootTag = rootTags.length > 0;

        // If the original event has no root tag, this is our root
        if (!hasRootTag) {
            tags.push(...event.referenceTags("root"));
        } else {
            // push the root tags from the original event
            tags.push(...rootTags);

            // and tag this event as a reply
            tags.push(...event.referenceTags("reply"));
        }

        // if this event has either a full or a preview tag, tag that too
        const fullTag = event.tagValue("full");
        const previewTag = event.tagValue("preview");

        if (fullTag) tags.push(["a", fullTag, "", "root"]);
        if (previewTag) tags.push(["a", previewTag, "", "root"]);

        console.log({ fullTag, previewTag });

        console.log(`returning tags`, tags);

        return tags;
    }

    async function debug() {
        debugView = true;
        await generateEvent();
        await reply?.sign();
        reply = reply;
    }

    async function generateEvent() {
        const rootTags = event.tags.filter(t => t[3] === "root");
        const hasRootTag = rootTags.length > 0;
        const hTag = event.tagValue("h");
        let kind = NDKKind.GroupNote;

        // If we are replying to a group note or group reply, this is a group reply
        if ([NDKKind.GroupNote, NDKKind.GroupReply].includes(event.kind)) kind = NDKKind.GroupReply;

        reply = new NDKEvent($ndk, {
            kind,
            content
        } as NostrEvent);

        if (!content || content.length === 0) return;

        if (hTag) {
            const userTier = $userActiveSubscriptions.get(hTag);

            reply.tags.push(["h", hTag]);
            if (userTier) reply.tags.push(["f", userTier]);
        }

        // Copy a and e tags for GroupNote and GroupReply
        if (event.kind === NDKKind.GroupNote || event.kind === NDKKind.GroupReply) {
            let tagsToCopy = event.tags.filter(t => t[0] === "a" || t[0] === "e");

            console.log("tagsToCopy before", tagsToCopy);

            // remove marker if it says "reply"
            tagsToCopy = tagsToCopy.map(t => {
                if (t[3] === "reply") t[3] = "";
                return t;
            });

            console.log("tagsToCopy after", tagsToCopy);

            reply.tags.push(...tagsToCopy);
        }

        // if we are replying to a GroupNote
        if (event.kind === NDKKind.GroupNote) {
            reply.tag(event, "reply")
            // if we are replying to a GroupReply
        } else if (event.kind === NDKKind.GroupReply) {
            reply.tag(event, "reply")
        } else {
            reply.tag(event);
        }
        // else

        // reply.tags.push(...getCommentTags());
    }

    async function publish() {
        await generateEvent();
        if (!reply) return;

        await reply.publish(getDefaultRelaySet());
        reply = reply;

        dispatch("published", reply);
    }
</script>

<UserProfile user={$user} let:userProfile>
    {#if !narrowView}
        <div class="flex flex-row gap-4 w-full">
            <Avatar user={$user} {userProfile} class="flex-none w-12 h-12" />

            <div class="flex flex-col gap-4 w-full items-start">
                <Name user={$user} {userProfile} class="text-white font-semibold leading-8" />
                <Textarea
                    class="
                        flex-grow w-full min-h-[10rem] border-base-200 focus:!border-base-300 round

                    "
                    placeholder="Write a response..."
                    bind:value={content}
                    on:focus
                    on:blur
                    on:submit={publish}
                />

                <div class="flex flex-row items-center justify-between w-full">
                    {#if $debugMode}
                        <button class="button button-primary px-10" on:click={debug}>Debug</button>
                    {/if}

                    <button class="button self-end px-10" on:click={publish}>Publish</button>
                </div>
            </div>
        </div>
    {:else}
        <div class="
            flex flex-col gap-4 w-full
    ">
            <div class="flex flex-row gap-4 w-full items-center">
                <Avatar user={$user} {userProfile} class="flex-none w-12 h-12" />
                <Name user={$user} {userProfile} class="text-white font-semibold leading-8" />
            </div>

            <div class="
                flex flex-col gap-4
                max-sm:w-screen max-sm:h-[100vh]
                max-sm:fixed max-sm:top-0 max-sm:left-0 max-sm:right-0 max-sm:bottom-0
                max-sm:bg-black max-sm:bg-opacity-50 max-sm:backdrop-filter max-sm:backdrop-blur-sm max-sm:overflow-scroll max-sm:z-50
            ">
                <Textarea
                    class="
                        flex-grow w-full min-h-[6rem] border-base-300 focus:!border-white/30 round
                        text-xl
                        !bg-transparent
                    "
                    placeholder="Write a response..."
                    on:focus
                    on:blur
                    on:submit={publish}
                    bind:value={content}
                />
                <div class="max-sm:w-full self-end">
                    <button class="button px-10 py-3" on:click={publish}>Publish</button>
                </div>
            </div>

            {#if $debugMode}
                <button class="button button-primary px-10" on:click={() => debugView = !debugView}>Debug</button>
            {/if}
        </div>
    {/if}

    {#if debugView && reply}
        <pre class="bg-base-200 p-4 overflow-scroll">{JSON.stringify(reply?.rawEvent(), null, 2)}</pre>
    {/if}
</UserProfile>

<!-- {#if reply}
    <pre>{JSON.stringify(reply?.rawEvent(), null, 4)}</pre>
{/if} -->