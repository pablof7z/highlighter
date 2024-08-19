<script lang="ts">
	import { goto } from "$app/navigation";
    import * as DropdownMenu from "$components/ui/dropdown-menu";
	import currentUser from "$stores/currentUser";
	import { eventKindToText } from "$utils/event";
	import { NDKEvent } from "@nostr-dev-kit/ndk";
	import { TrashSimple } from "phosphor-svelte";
	import { createEventDispatcher } from "svelte";
	import { toast } from "svelte-sonner";

    export let event: NDKEvent;

    const dispatch = createEventDispatcher();

    const DELETE_DELAY = 5000;

    let isUser: boolean;

    $: isUser = $currentUser?.pubkey === event.pubkey;

    let deleteTimeout: any;

    const eventUrl = window.location.href;

    async function deleteEvent() {
        if (event.isParamReplaceable()) {
            // overwrite with no content and add deleted tag
            const dTag = event.dTag;
            event.content = "";
            event.tags = [ [ "deleted" ]];
            if (dTag) event.tags.push(["d", dTag]);
            event.publishReplaceable();
        }
        
        const r = await event.delete();
        console.log(r.rawEvent());
    }

    function clicked(e: Event) {
        deleteTimeout = setTimeout(() => {
            deleteEvent();
        }, DELETE_DELAY);

        const type = eventKindToText(event.kind)
        
        toast(type+" deleted", {
            action: {
                label: "Undo",
                onClick: () => {
                    clearTimeout(deleteTimeout);
                    dispatch('delete:cancel', event)
                    goto(eventUrl);
                    toast.success(type+" restored");
                }
            },
            duration: DELETE_DELAY
        })

        dispatch('delete', event);
    }
</script>

{#if isUser}
    <DropdownMenu.Separator />
    
    <DropdownMenu.Item class="text-red-500" on:click={clicked}>
        <TrashSimple class="mr-2" />
        Delete
    </DropdownMenu.Item>
{/if}