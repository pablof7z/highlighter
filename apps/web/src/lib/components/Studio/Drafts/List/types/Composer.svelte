<script lang="ts">
	import { DraftItem } from "$stores/drafts";
    import * as Composer from "$components/Composer";
    import * as Card from "$components/ui/card";
	import { getStateFromDraft } from "$components/Studio/draft";
	import { NDKEvent } from "@nostr-dev-kit/ndk";
	import { generateEventFromState } from "$components/Composer/actions/publish";
	import currentUser from "$stores/currentUser";
	import { toast } from "svelte-sonner";
	import { EventContent } from "@nostr-dev-kit/ndk-svelte-components";
	import { ndk } from "$stores/ndk";
	import { openModal } from "$utils/modal";
	import NewPostModal from "$modals/NewPostModal.svelte";
	import { writable } from "svelte/store";

    export let item: DraftItem;
    let state: Composer.State | undefined;
    let event: NDKEvent | undefined;

    try {
        state = getStateFromDraft(item);
        if (state) {
            event = generateEventFromState(state);
            if ($currentUser) event.pubkey = $currentUser.pubkey;
        }
    } catch (e) {
        console.error(e)
        toast.success("Draft is not supported", { description: e.message });
    }

    function open() {
        const stateStore = writable(state);
        openModal(NewPostModal, {state: stateStore});
    }
</script>

{#if event}
    <button class="text-left w-full" on:click={open}>
        <Card.Root class="bg-secondary max-h-[10rem] overflow-y-auto">
            <Card.Content>
                <EventContent ndk={$ndk} event={event} />
            </Card.Content>
        </Card.Root>
    </button>
{/if}