<script lang="ts">
	import ModalShell from "$components/ModalShell.svelte";
    import Input from "$components/Forms/Input.svelte";
	import NewPost from "$components/Feed/NewPost/NewPost.svelte";
	import { Hexpubkey, NDKEvent, NDKHighlight, NDKKind, NDKTag, NDKUser } from "@nostr-dev-kit/ndk";
	import AvatarWithName from "$components/User/AvatarWithName.svelte";
	import { closeModal } from "$utils/modal";

    export let tags: NDKTag[] = [];
    export let onPublish: ((event: NDKEvent) => void) | undefined = undefined;
    export let creator: NDKUser | undefined = undefined;
    export let groupId: Hexpubkey = creator ? creator.pubkey : "";

    let publishing = false;

    let extraTags: NDKTag[] = [];
    let title = "";

    $: {
        extraTags = [ [ "h", groupId ] ];
        if (title?.length > 0) {
            extraTags.push([ "title", title ]);
        }
        extraTags = extraTags;
    }
</script>

<ModalShell color="glassy" class="w-full sm:max-w-2xl !p-2 {publishing ? "!bg-transparent" : ""}">
    {#if publishing}
        <div class="loading loading-lg loading-dots"></div>
    {/if}

    <div class="w-full flex flex-col">
        <Input
            color="black"
            class="border-none text-xl"
            bind:value={title}
            placeholder="What is this thread about?" autofocus={true}
        />
        <NewPost
            kind={NDKKind.GroupNote}
            placeholder="What are your thoughts?"
            editorClass="text-white min-h-[7rem]"
            skipAvatar={true}
            collapsed={false}
            autofocus={false}
            extraTags={tags}
            bind:publishing
            on:publish={() => {
                closeModal();
                onPublish?.(event);
            }}
            on:cancel={closeModal}
        >
            <div slot="buttonsBar" class="w-full ">
                {#if creator}
                    <AvatarWithName user={creator} avatarSize="small" class="text-base font-medium text-base-100-content">
                        <div class="text-xs opacity-50">Subscribers-only thread</div>
                    </AvatarWithName>
                {/if}
            </div>
        </NewPost>
    </div>
</ModalShell>