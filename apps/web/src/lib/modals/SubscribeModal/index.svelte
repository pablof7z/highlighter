<script lang="ts">
	import ModalShell from "$components/ModalShell.svelte";
	import { NDKEvent, NDKKind } from "@nostr-dev-kit/ndk";
	import { NavigationOption } from "../../../app";
	import RadioButton from "$components/Forms/RadioButton.svelte";
	import Name from "$components/User/Name.svelte";
	import { Inbox } from "lucide-svelte";
    import * as Groups from "$components/Groups";
	import GroupItem from "./GroupItem.svelte";
	import { derived, Readable } from "svelte/store";
	import { userFollows } from "$stores/session";
	import Checkbox from "$components/Forms/Checkbox.svelte";
	import CheckButton from "$components/Forms/CheckButton.svelte";
	import Button from "$components/ui/button/button.svelte";

    export let event: NDKEvent | undefined = undefined;
    export let group: Readable<Groups.GroupData> | undefined = undefined;

    const hTags = event?.getMatchingTags("h");
    const author = event?.author;

    let currentValue = '';
    
    const actionButtons: NavigationOption[] = [
        {
            name: 'Cancel',
            buttonProps: { variant: 'link' }
        },
        {
            name: "Subscribe",
            buttonProps: { variant: 'accent' }
        }
    ];
</script>

<ModalShell
    {actionButtons}
    title="Subscribe"
>

    <div class="flex flex-col gap-2">

        {#if hTags && hTags.length === 0}
            <RadioButton value="free" bind:currentValue>
                Inbox
                <svelte:fragment slot="description">
                    Add
                    <Name user={author} class="text-semibold text-primary" />
                    to your inbox
                </svelte:fragment>
                <Inbox slot="icon" />
            </RadioButton>
        {:else if group && $group}
            <GroupItem {group} bind:currentValue />
        {:else if hTags}
            <Groups.RootList tags={hTags} let:group>
                <GroupItem {group} bind:currentValue />
            </Groups.RootList>
        {/if}
    </div>
</ModalShell>