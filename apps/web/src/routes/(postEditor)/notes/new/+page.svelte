<script lang="ts">
	import { publishToTiers } from "$actions/publishToTiers";
    import UserProfile from "$components/User/UserProfile.svelte";
	import Page1 from "$components/Editor/NoteEditorPage/Page1.svelte";
	import { type TierSelection, getTierSelectionFromAllTiers, getSelectedTiers } from "$lib/events/tiers";
	import { getUserSupportPlansStore } from "$stores/user-view";
	import { ndk, newToasterMessage, user } from "@kind0/ui-common";
	import { NDKEvent, NDKKind, type NostrEvent } from "@nostr-dev-kit/ndk";

	import type { UserProfileType } from "../../../../app.d.ts";
	import Shell from "$components/PostEditor/Shell.svelte";

    const allTiers = getUserSupportPlansStore();
    let tiers: TierSelection = { "Free": { name: "Free", selected: true } };
    $: tiers = getTierSelectionFromAllTiers($allTiers);

    let publishing = false;

    function getNoteKind() {
        const hasFreeTier = tiers["Free"].selected;
        if (hasFreeTier && wideDistribution) {
            return NDKKind.Text;
        }

        return NDKKind.GroupNote;
    }

    function getPreviewKind() {
        if (wideDistribution) {
            return NDKKind.Text;
        } else {
            return NDKKind.GroupNote;
        }
    }

    async function publish() {
        publishing = true;

        note.kind = getNoteKind();
        preview.kind = getPreviewKind();

        // append all uploaded files to the note's content separated by new lines
        if (uploadedFiles.length > 0) {
            note.content += "\n\n" + uploadedFiles.join("\n");
        }

        const selectedTiers = getSelectedTiers(tiers);

        // Don't create a preview article if all tiers are selected
        if (selectedTiers.length === Object.values(tiers).length) {
            nonSubscribersPreview = false;
        }

        try {
            await publishToTiers(note, tiers, {
                ndk: $ndk,
                teaserEvent: nonSubscribersPreview ? preview : undefined,
                wideDistribution
            });
        } catch (e: any) {
            --step;
            console.error(e);
            newToasterMessage("Failed to publish note: "+e?.message, "error");
        } finally {
            publishing = false;
        }
    }

    let note = new NDKEvent($ndk, {
        kind: NDKKind.GroupNote,
        pubkey: $user.pubkey,
        content: "",
    } as NostrEvent);
    let preview = new NDKEvent($ndk, {
        kind: NDKKind.GroupNote,
        content: "",
    } as NostrEvent);

    let uploadedFiles: string[] = [];

    let step = 0;

    let userProfile: UserProfileType;
    let authorUrl: string;
    let nonSubscribersPreview: boolean = false;
    let wideDistribution: boolean = true;
</script>

<svelte:head>
    <title>New note</title>
</svelte:head>

<UserProfile user={$user} bind:userProfile bind:authorUrl />

<Shell type="note" {note}>
    <Page1
        bind:note
        bind:uploadedFiles
    />
</Shell>

<!-- <MainWrapper class="p-6">
    <ItemEditShell
        bind:step
        bind:steps={steps}
    >
        {#if step === 0}

        {/if}

        <div class:hidden={step !== 1}>
            <DistributionPage
                type="note"
                {tiers}
                bind:nonSubscribersPreview
                bind:wideDistribution
                bind:canContinue={steps[2].canContinue}
                on:changed={tiersChanged}
                on:editPreview={editTeaser}
            />
        </div>

        {#if step === 2}
            {#if $debugMode}
                <pre>{JSON.stringify({
                    wideDistribution,
                    tiers
                })}</pre>
                <pre>{JSON.stringify(note.rawEvent(), null, 2)}</pre>
                <pre>{JSON.stringify(preview.rawEvent(), null, 2)}</pre>
            {:else}
                <PublishingStep {publishing}>
                    <div slot="preview">
                        <FeedGroupPost event={note} class="!py-5 border border-base-300" />
                    </div>
                </PublishingStep>
            {/if}
        {/if}
    </ItemEditShell>
</MainWrapper> -->

<style lang="postcss">
    .attachments img {
        /* Make the object cover be positioned at the top-left */
        @apply object-left-top;
    }
</style>