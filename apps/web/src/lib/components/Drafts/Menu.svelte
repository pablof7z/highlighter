<script lang="ts">
	import { RelativeTime, ndk } from '@kind0/ui-common';
	import currentUser from '$stores/currentUser';
    import { drafts } from "$stores/drafts";
	import { Microphone, Play, RowsPlusBottom, TextAlignLeft, Timer, Trash } from "phosphor-svelte";
	import DraftItem from "$components/Creator/DraftItem.svelte";
	import DraftListVersionItem from "$components/Creator/DraftListVersionItem.svelte";
	import { Thread, saveDraft } from '$utils/thread';
	import { NDKKind } from '@nostr-dev-kit/ndk';
	import { goto } from '$app/navigation';

    function trash(id: string) {
        $drafts = $drafts.filter(d => d.id !== id);
    }

    function newThread() {
        const thread = new Thread(NDKKind.Text, $currentUser!, $ndk);
        const draftItem = saveDraft(false, undefined, drafts, thread);
        $drafts = $drafts;
        goto(`/drafts/${draftItem.id}`);
    }
</script>

{#if $currentUser}
    <ul class="w-full discussion-wrapper">
        {#key $drafts}
            {#if $drafts.length === 0}
                No drafts yet.
            {/if}
            {#each $drafts as draft (draft.id)}
                <div class="discussion-item">
                <div class="max-h-[25vh] overflow-hidden">
                    <DraftItem item={draft} />
                </div>
                <div class="flex flex-row justify-between items-center">
                    <button class="flex flex-row items-center group whitespace-nowrap" on:click={() => trash(draft.id)}>
                        <Trash class="w-5 h-5" weight="light" />
                        <span class="max-w-0 truncate group-hover:max-w-[5rem] text-white whitespace-nowrap line-clamp-1 ml-2 transition-all duration-300">
                            Delete
                        </span>
                    </button>

                    <div class="dropdown dropdown-end">
                        <!-- svelte-ignore a11y-no-noninteractive-tabindex -->
                        <!-- svelte-ignore a11y-label-has-associated-control -->
                        <button class="flex flex-row items-center group whitespace-nowrap" tabindex="0">
                            <span class="max-w-0 truncate group-hover:max-w-[5rem] text-white whitespace-nowrap line-clamp-1 mr-2 transition-all duration-300">
                                Versions
                            </span>
                            <Timer class="w-5 h-5" />
                        </button>
                        <!-- svelte-ignore a11y-no-noninteractive-tabindex -->
                        <ul tabindex="0" class="dropdown-content z-[1] menu p-2 shadow bg-base-100 rounded-box">
                            {#each JSON.parse(draft.checkpoints) as checkpoint}
                                <DraftListVersionItem {draft} {checkpoint} />
                            {/each}
                        </ul>
                    </div>
                </div>
                <div class="text-xs font-light opacity-50 text-center w-full">
                    <RelativeTime timestamp={JSON.parse(draft.checkpoints)[0].time} />
                </div>
                </div>
            {/each}
        {/key}
    </ul>
{/if}

<style>
    ul {
        @apply flex flex-col;
    }

    .bg {
        background: radial-gradient(100.21% 187.14% at 0% 0.15%, #BD9488aa 0%, #7092A0aa 100%);
    }

    a {
        @apply bg-white/5 hover:bg-white/10;
        @apply transition-all duration-300;
    }
</style>