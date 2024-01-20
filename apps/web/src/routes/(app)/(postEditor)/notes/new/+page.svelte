<script lang="ts">
	import { publishToTiers } from "$actions/publishToTiers";
	import { goto } from "$app/navigation";
    import NotePreviewEditorModal from "$modals/NotePreviewEditorModal.svelte";
    import UserProfile from "$components/User/UserProfile.svelte";
	import Page1 from "$components/Editor/NoteEditorPage/Page1.svelte";
	import DistributionPage from "$components/Editor/Pages/DistributionPage.svelte";
	import ItemEditShell from "$components/Forms/ItemEditShell.svelte";
	import { type TierSelection, getTierSelectionFromAllTiers, getSelectedTiers } from "$lib/events/tiers";
	import { getUserSupportPlansStore } from "$stores/user-view";
	import { ndk, newToasterMessage, UploadButton, user } from "@kind0/ui-common";
	import { NDKEvent, NDKKind, type NostrEvent } from "@nostr-dev-kit/ndk";

	import type { UserProfileType } from "../../../../../app";
	import { openModal } from "svelte-modals";
	import { fade } from "svelte/transition";
	import PublishingStep from "$components/Editor/Pages/PublishingStep.svelte";
	import { debugMode } from "$stores/session";
	import MainWrapper from "$components/Page/MainWrapper.svelte";

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

    function tiersChanged(e: CustomEvent<TierSelection>) {
        tiers = e.detail;
    }

    let note = new NDKEvent($ndk, {
        kind: NDKKind.GroupNote,
        content: "",
    } as NostrEvent);
    let preview = new NDKEvent($ndk, {
        kind: NDKKind.GroupNote,
        content: "",
    } as NostrEvent);

    let uploadedFiles: string[] = [];

    let step = 0;

    let steps = [
        {
            title: "Write",
            description: "Write to your heart's content",
            canContinue: true,
        },
        {
            title: "Audience",
            description: "Define this article's visibility",
            canContinue: true,
        },
        {
            title: "Publish",
            description: "Publish this article",
            canContinue: true,
        }
    ]

    let userProfile: UserProfileType;
    let authorUrl: string;
    let nonSubscribersPreview: boolean = true;
    let wideDistribution: boolean = true;

    function editTeaser() {
        openModal(NotePreviewEditorModal, {
            note,
            preview,
            authorLink: `https://getfaaans.com/${authorUrl}`,
        });
    }
</script>

<UserProfile user={$user} bind:userProfile bind:authorUrl />

<MainWrapper class="p-6">
    <ItemEditShell
        bind:step
        on:publish={publish}
        bind:steps={steps}
    >
        {#if step === 0}
            <Page1
                bind:note
                bind:uploadedFiles
            />
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
                <div transition:fade={{duration: 1000}}>
                    <PublishingStep
                        {publishing}
                    />
                </div>
            {/if}
        {/if}
    </ItemEditShell>
</MainWrapper>

<style lang="postcss">
    .attachments img {
        /* Make the object cover be positioned at the top-left */
        @apply object-left-top;
    }
</style>