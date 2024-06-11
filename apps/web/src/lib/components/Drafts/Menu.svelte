<script lang="ts">
	import NewItemModal from '$modals/NewItemModal.svelte';
	import currentUser from '$stores/currentUser';
    import { drafts } from "$stores/drafts";
	import { Timer, Trash } from "phosphor-svelte";
	import DraftItem from "$components/Creator/DraftItem.svelte";
	import DraftListVersionItem from "$components/Creator/DraftListVersionItem.svelte";
	import PageTitle from '$components/PageElements/PageTitle.svelte';
	import { openModal } from '$utils/modal';
	import BlankState from '$components/PageElements/BlankState.svelte';
	import { appMobileHideNewPostButton } from '$stores/app';
    import { pageHeader } from '$stores/layout';
	import RelativeTime from '$components/PageElements/RelativeTime.svelte';

	$pageHeader = { title: 'Drafts' }

    $appMobileHideNewPostButton = true;
    
    function trash(id: string) {
        $drafts = $drafts.filter(d => d.id !== id);
    }

</script>

{#if $drafts.length > 0}
    <PageTitle title="Drafts" />
{/if}


{#if $drafts.length === 0}
    <BlankState
        cta="Start making one"
        on:click={() => openModal(NewItemModal)}
        class="md:fixed md:top-1/2 md:-translate-y-1/2 md:left-1/2 md:-translate-x-1/2"
    >
        <img src="/images/drafts.png" class="mx-auto w-3/5 h-3/5 opacity-60 my-8" />
        <blockquote slot="afterCta" class="app-quote relative my-8">
            <p class="z-1 relative text-muted-foreground text-lg font-[Filosofia]">
                “And what can life be worth if the first rehearsal for life is life itself? That is why life is always like a sketch. No, "sketch" is not quite a word, because a sketch is an outline of something, the groundwork for a picture, whereas the sketch that is our life is a sketch for nothing, an outline with no picture.”
            </p>

            <div class="author">
                Milan Kundera
            </div>
        </blockquote>
        
        <span class="text-2xl font-semibold">Life is always a draft,</span>
        <br>
        <span class="font-light text-muted-foreground">but you don't have one here.</span>
    </BlankState>
{:else if $currentUser}
    <ul class="w-full discussion-wrapper">
        {#key $drafts}
            {#each $drafts as draft (draft.id)}
                <div class="discussion-item">
                <div class="max-h-[25vh] overflow-hidden">
                    <DraftItem item={draft} />
                </div>
                <div class="flex flex-row justify-between items-center">
                    <button class="flex flex-row items-center group whitespace-nowrap" on:click={() => trash(draft.id)}>
                        <Trash class="w-5 h-5" weight="light" />
                        <span class="max-w-0 truncate group-hover:max-w-[5rem] text-foreground whitespace-nowrap line-clamp-1 ml-2 transition-all duration-300">
                            Delete
                        </span>
                    </button>

                    <div class="dropdown dropdown-end">
                        <!-- svelte-ignore a11y-no-noninteractive-tabindex -->
                        <!-- svelte-ignore a11y-label-has-associated-control -->
                        <button class="flex flex-row items-center group whitespace-nowrap" tabindex="0">
                            <span class="max-w-0 truncate group-hover:max-w-[5rem] text-foreground whitespace-nowrap line-clamp-1 mr-2 transition-all duration-300">
                                Versions
                            </span>
                            <Timer class="w-5 h-5" />
                        </button>
                        <!-- svelte-ignore a11y-no-noninteractive-tabindex -->
                        <ul tabindex="0" class="dropdown-content z-[1] menu p-2 shadow bg-background rounded-box">
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
</style>