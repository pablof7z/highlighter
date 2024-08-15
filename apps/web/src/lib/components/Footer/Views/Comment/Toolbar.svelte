<script lang="ts">
	import { createEventReply } from '$utils/event';
	import { OpenFn } from "$components/Footer";
	import { Button } from "$components/ui/button";
	import { Writable } from "svelte/store";
	import { State } from ".";
	import { NDKEvent } from '@nostr-dev-kit/ndk';
	import { toast } from 'svelte-sonner';
	import { Image } from 'phosphor-svelte';

    export let open: OpenFn;
    export let stateStore: Writable<State>;
    export let event: NDKEvent;

    function cancel() {
        open(false);
    }

    async function publish() {
        $stateStore.actions!.publish();
        $stateStore.actions = undefined;
        $stateStore.state = undefined;
        toast.success('Reply published');
        open(false)
    }
</script>

<div class="flex flex-row justify-between w-full">
    <Button variant="link" on:click={cancel}>
        Cancel
    </Button>

    <div class="flex flex-row gap-4">
        <Button variant="secondary" size="icon" on:click={() => $stateStore.actions?.upload() }>
            <Image size={16} />
        </Button>

        <Button on:click={publish}>
            Publish
        </Button>
    </div>
</div>