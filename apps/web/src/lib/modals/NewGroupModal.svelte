<script lang="ts">
	import ModalShell from "$components/ModalShell.svelte";
	import Input from "$components/ui/input/input.svelte";
	import { NavigationOption } from "../../app";
    import InputArray from "$components/ui/input/array.svelte";
	import { defaultRelays } from "$utils/const";
	import { NDKEvent, NDKRelaySet, NDKSimpleGroup } from "@nostr-dev-kit/ndk";
	import { ndk } from "$stores/ndk";
	import Textarea from "$components/ui/textarea/textarea.svelte";
	import { closeModal } from "$utils/modal";
	import { groupsList } from "$stores/session";

    let name: string;
    let picture: string;
    let relays: string[] = defaultRelays;
    const actionButtons: NavigationOption[] = [
        {
            name: "Create",
            buttonProps: {variant: 'accent'},
            fn: create,
        },
    ];

    async function create() {
        const relaySet = NDKRelaySet.fromRelayUrls(relays, $ndk);

        const group = new NDKSimpleGroup($ndk, relaySet);
        await group.createGroup();
        await group.setMetadata({ name, picture });

        $groupsList?.addItem([ "group", group.groupId, ...relaySet.relayUrls ])
        $groupsList?.publishReplaceable();

        closeModal();
    }
</script>

<ModalShell
    title="Create New Community"
    {actionButtons}
>
    <Input bind:value={name} placeholder="Community Name" />

    <Input bind:value={picture} placeholder="Image" />

    <div class="font-bold">Relays</div>
    <InputArray bind:values={relays} />
</ModalShell>