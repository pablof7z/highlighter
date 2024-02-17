<script lang="ts">
	import Page1 from "$components/Editor/NoteEditorPage/Page1.svelte";
	import { type TierSelection, getTierSelectionFromAllTiers, getSelectedTiers } from "$lib/events/tiers";
	import { getUserSubscriptionTiersStore } from "$stores/user-view";
    import { preview, event, type } from "$stores/post-editor.js";
	import { ndk, user } from "@kind0/ui-common";
	import { NDKEvent, NDKKind, type NostrEvent } from "@nostr-dev-kit/ndk";

	import Shell from "$components/PostEditor/Shell.svelte";

    const allTiers = getUserSubscriptionTiersStore();
    let tiers: TierSelection = { "Free": { name: "Free", selected: true } };
    $: tiers = getTierSelectionFromAllTiers($allTiers);

    let note = new NDKEvent($ndk, {
        kind: NDKKind.GroupNote,
        pubkey: $user.pubkey,
        content: "",
    } as NostrEvent);

    let uploadedFiles: string[] = [];
</script>

<svelte:head>
    <title>New note</title>
</svelte:head>

<Shell type="note" {note}>
    <Page1
        bind:note
        bind:uploadedFiles
    />
</Shell>
