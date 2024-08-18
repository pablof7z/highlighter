<script lang="ts">
	import ModalShell from "$components/ModalShell.svelte";
	import Input from "$components/ui/input/input.svelte";
	import { NavigationOption } from "../../app";
    import InputArray from "$components/ui/input/InputArray.svelte";
	import { defaultRelays } from "$utils/const";
	import { NDKEvent, NDKKind, NDKList, NDKRelaySet, NDKSimpleGroup } from "@nostr-dev-kit/ndk";
	import { ndk } from "$stores/ndk";
	import { closeModal } from "$utils/modal";
	import { groupsList } from "$stores/session";
	import { toast } from "svelte-sonner";
    import { Keyboard } from '@capacitor/keyboard';

    if (isMobileBuild()) {
        onMount(() => {
            try { Keyboard.show(); } catch {}
        });
    }

    import * as Collapsible from "$lib/components/ui/collapsible";
	import BlossomUpload from "$components/buttons/BlossomUpload.svelte";
	import { Camera, CaretDown, Image, Upload } from "phosphor-svelte";
	import ContentEditor from "$components/Forms/ContentEditor.svelte";
	import { Button } from "$components/ui/button";
	import { onMount } from "svelte";
	import { appMobileView } from "$stores/app";
	import { isMobileBuild } from "$utils/view/mobile";
	import { writable } from "svelte/store";


    let name: string;
    let picture: string;
    let about: string;
    let relays = writable<string[]>(defaultRelays);
    const actionButtons: NavigationOption[] = [
        {
            name: "Next",
            class: 'w-full',
            buttonProps: {variant: 'default', class: 'w-full'},
            fn: create,
        },
    ];

    async function create() {
        const relaySet = NDKRelaySet.fromRelayUrls($relays, $ndk);

        const group = new NDKSimpleGroup($ndk, relaySet);
        const randomNumber = Math.floor(Math.random() * 1000000);
        group.groupId = 'group' + randomNumber;
        const published = await group.createGroup();
        if (!published) {
            toast.error("Failed to create group");
            return;
        }
        await group.setMetadata({ name, picture, about });

        $groupsList ??= new NDKList($ndk);
        $groupsList.kind = NDKKind.SimpleGroupList;

        $groupsList.addItem([ "group", group.groupId, ...relaySet.relayUrls ])
        $groupsList.publishReplaceable();

        closeModal();
    }

    function uploaded(e) {
        picture = e.detail.url;
    }
</script>

<ModalShell
    class="responsive-padding"
    title="New Publication"
    {actionButtons}
>
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
                <Input bind:value={name} placeholder="Publication Name" class="text-xl py-6" autofocus />
            </div>
        </div>

        <ContentEditor
            bind:content={about}
            allowMarkdown={false}
            toolbar={false}
            class="
                text-lg border border-border p-4 rounded
            "
            placeholder="Publication Description"
        />
    </div>

    <Collapsible.Root class="mt-8">
        <Collapsible.Trigger class="text-xs w-full">
            <Button variant="outline" class="w-full justify-start">
                Advanced
                <CaretDown size={16} class="ml-auto" />
            </Button>
        </Collapsible.Trigger>
        <Collapsible.Content>
            <div class="font-bold">Relays</div>
            <InputArray bind:values={relays} />
        </Collapsible.Content>
    </Collapsible.Root>
</ModalShell>