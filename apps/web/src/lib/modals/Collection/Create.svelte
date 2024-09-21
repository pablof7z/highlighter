<script lang="ts">
	import { closeModal } from '$utils/modal';
	import { ndk } from '$stores/ndk.js';
	import { NavigationOption } from './../../../app.d.js';
	import { NDKEvent, NDKList } from '@nostr-dev-kit/ndk';
	import ModalShell from "$components/ModalShell.svelte";
	import { Input } from '$components/ui/input';
    import { getCurationKind } from '$utils/event';
    
    export let event: NDKEvent | undefined = undefined;
    export let curationKind = event ? getCurationKind(event) : undefined;

    export let name: string = "";

    async function fn() {
        const list = new NDKList($ndk)
        list.kind = curationKind;
        list.addItem(event);
        list.title = name;
        list.dTag = 'ujohzhztu5iv6mxe'
        list.publish();
        closeModal();
    }

    const actionButtons: NavigationOption[] = [
        { name: "Create", buttonProps: { variant: 'accent' }, fn }
    ]
</script>

<ModalShell
    title="Create New Collection"
    {actionButtons}
>
    <div class="flex flex-col gap-2">
        <Input
            bind:value={name}
            placeholder="Enter collection name"
            class="w-full"
        />
    </div>
</ModalShell>
