<script lang="ts">
	import { publishToTiers } from "$actions/publishToTiers";
	import SelectTier from "$components/Forms/SelectTier.svelte";
	import PageTitle from "$components/Page/PageTitle.svelte";
	import { getUserSupportPlansStore } from "$stores/user-view";
	import { Textarea, ndk } from "@kind0/ui-common";
	import { NDKEvent, NDKKind, type NostrEvent } from "@nostr-dev-kit/ndk";

    const allTiers = getUserSupportPlansStore();

    let tiers: Record<string, boolean> = { "Free": false };
    let content: string;

    $: for (const tier of $allTiers) {
        if (tiers[tier.title] === undefined) {
            tiers[tier.title] = false;
        }
    }

    async function publish() {
        const note = new NDKEvent($ndk, {
            kind: NDKKind.GroupNote,
            content,
        } as NostrEvent);

        publishToTiers(note, tiers);
    }
</script>

<div class="flex flex-col gap-10">
    <PageTitle title="New Note">
        <div class="flex flex-row gap-2">
            <button on:click={publish} class="button px-10">Publish</button>
        </div>
    </PageTitle>

    <Textarea
        bind:value={content}
        autofocus={true}
        class="w-full border bg-base-200 border-neutral-800 rounded-xl resize-none min-h-[20rem] text-lg text-white p-6"
    />

    <SelectTier bind:tiers />
</div>

