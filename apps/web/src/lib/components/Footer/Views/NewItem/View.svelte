<script lang="ts">
	import { openModal } from "$utils/modal";
	import NewPostModal from "$modals/NewPostModal.svelte";
	import { createEventDispatcher } from "svelte";
	import NewGroupModal from "$modals/NewGroupModal.svelte";
	import NewPostItem from "$components/Creator/NewPostItem.svelte";
	import { NDKSimpleGroup, NDKSimpleGroupMetadata } from "@nostr-dev-kit/ndk";
	import * as Audience from "$components/Audience";
	import { Readable } from "svelte/store";
	import { Group } from "$components/Groups";

    export let onNewShortPost: (() => void) | undefined = undefined;
    export let group: Readable<Group> | undefined = undefined;

    const dispatch = createEventDispatcher();

    function shortNote() {
        let audience: Audience.State = {
            scope: 'public'
        };

        if ($group) {
            audience.scope =  "private";
            audience.groups = [ $group ];
            console.log('audience', audience)
        }
            
        openModal(NewPostModal, { audience });
        dispatch("close");
    }

    function newCommunity() {
        dispatch("close");
        openModal(NewGroupModal);
    }

    function close() {
        dispatch("close");
    }

    function url(path: string) {
        const uri = new URL(path, window.location.origin);

        if ($group) {
            uri.searchParams.set("group", $group.id);
            for (const relay of $group.relayUrls) {
                uri.searchParams.append("relay", relay);
            }
        }

        return uri.toString();
    }
</script>

<div class="flex flex-col gap-2">
    {#if $group?.metadata}
        <div class="bg-background/50 border p-4 rounded font-medium text-muted-foreground flex flex-row items-center gap-2">
            {#if $group.metadata.picture}
                <img src={$group.metadata.picture} class="w-12 h-12 rounded-full object-cover" />
            {/if}

            New Post on
            
            <span class="text-foreground font-bold">{$group.metadata.name}</span>
        </div>
    {/if}
    
    <div class="
        gap-3
        w-full
        grid md:grid-flow-row
        grid-cols-2 md:grid-cols-2
        justify-center
    ">
        <NewPostItem icon='🤙' title="Short Note" on:click={shortNote} />
        <NewPostItem icon="🗒️" title="Article" href={url("/studio/article")} on:click={close} />
        <NewPostItem icon='🎬 ' title="Video" href={url("/studio/video")} on:click={close} />
        <NewPostItem icon='🧵' title="Thread" href={url("/studio/threads/new")} on:click={close} />
        {#if !$group}
            <NewPostItem icon='🏰' title="Community" on:click={newCommunity} class="col-span-2" />
        {/if}
        
    </div>

</div>