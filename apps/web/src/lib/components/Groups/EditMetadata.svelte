<script lang="ts">
	import Input from "$components/ui/input/input.svelte";
	import { defaultRelays } from "$utils/const";
	import { NDKRelaySet, NDKSimpleGroup, NDKSimpleGroupMetadata } from "@nostr-dev-kit/ndk";
	import { ndk } from "$stores/ndk";
	import { groupsList } from "$stores/session";
	import { toast } from "svelte-sonner";

	import BlossomUpload from "$components/buttons/BlossomUpload.svelte";
	import { Camera } from "phosphor-svelte";
	import ContentEditor from "$components/Forms/ContentEditor.svelte";
	import { createEventDispatcher, getContext } from "svelte";
	import Checkbox from "$components/Forms/Checkbox.svelte";
	import { Readable } from "svelte/store";

    export let group: NDKSimpleGroup | undefined = undefined;
    export let forceSave: boolean = false;
    export let metadata = getContext("groupMetadata") as Readable<NDKSimpleGroupMetadata | undefined>;

    const dispatch = createEventDispatcher();

    $: if (forceSave) {
        forceSave = false;
        save();
    }

    let name: string = $metadata?.name ?? "";
    let picture: string = $metadata?.picture ?? "";
    let about: string = $metadata?.about ?? "";
    let relays: string[] = group?.relayUrls() ?? defaultRelays;

    async function save() {
        const relaySet = group?.relaySet ?? NDKRelaySet.fromRelayUrls(relays, $ndk);

        const createGroup = !group;

        group ??= new NDKSimpleGroup($ndk, relaySet);

        if (createGroup) {
            const randomNumber = Math.floor(Math.random() * 1000000);
            group.groupId = 'group-' + randomNumber;
            const published = await group.createGroup();
            if (!published) {
                toast.error("Failed to create group");
                return;
            }
        }
        
        await group.setMetadata({ name, picture, about });

        if (createGroup) {
            $groupsList?.addItem([ "group", group.groupId, ...relaySet.relayUrls ])
            $groupsList?.publishReplaceable();
        }

        dispatch("saved", { group });
    }

    function uploaded(e) {
        picture = e.detail.url;
    }

    let privateScope: boolean = group?.metadata?.scope === "private" ?? false;
</script>

<div class="flex flex-col gap-6">
    <div class="flex flex-row items-center gap-4">
        <BlossomUpload type="image" on:uploaded={uploaded}>
            <button class="h-16 w-16 relative rounded-full overflow-clip flex flex-row items-center justify-center bg-accent/50">
                {#if picture}
                    <img src={picture} class="absolute w-full h-full object-cover z-0 opacity-50" />
                {/if}
                <Camera size={32} class="z-10" />
            </button>
        </BlossomUpload>

        <div class="flex flex-col w-full">
            <Input bind:value={name} placeholder="Community Name" class="text-xl py-6" />
        </div>
    </div>

    <ContentEditor
        bind:content={about}
        allowMarkdown={false}
        toolbar={false}
        class="
            text-lg border border-border p-4 rounded
        "
        placeholder="Community Description"
    />

    <div class="border p-4 rounded">
        <Checkbox bind:value={privateScope}>
            Allow non-members to see the content of this community
        </Checkbox>
    </div>
</div>
