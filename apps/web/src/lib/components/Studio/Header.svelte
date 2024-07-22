<script lang="ts">
    import Button from "$components/ui/button/button.svelte";
	import { CaretLeft, Eye, PaperPlaneTilt, Timer, UsersThree, X } from "phosphor-svelte";
	import { Readable, Writable } from "svelte/store";
    import * as Tooltip from "$lib/components/ui/tooltip";
	import { NDKArticle, NDKSimpleGroup, NDKVideo } from "@nostr-dev-kit/ndk";
	import { closeModal, openModal } from "$utils/modal";
	import ScheduleModal from "$modals/ScheduleModal.svelte";
	import ToggleDark from "$components/buttons/ToggleDark.svelte";
	import { goto } from "$app/navigation";
	import { PublishInGroupStore } from ".";
	import { pluralize } from "$utils";

    export let mode: Writable<string>;
    export let publishing: Writable<boolean>;
    export let publishAt: Writable<Date | undefined>;
    export let event: Writable<NDKArticle | NDKVideo | undefined>;
    export let groups: Readable<Record<string, NDKSimpleGroup>>;
    export let publishInGroups: PublishInGroupStore;

    export let onPublish: () => Promise<void>;
    
    let closing: any;
    function closeClicked() {
        if (closing) {
            goto("/");
        } else {
            closing = setTimeout(() => {
                closing = false;
            }, 2000);
        }
    }

    function setMode(m: string) {
        return () => { $mode = m; }
    }

    async function schedule(
        schedule = false
    ) {
        let action: string;

        // if ($type === "thread") {
        //     const length = $event.items.length;

        //     action = "Thread will be published";

        //     if (length === 1) {
        //         action = "Post will be published";
        //     }
        // } else {
            action = "Publish"
        // }

        openModal(ScheduleModal, {
            title: `Schedule`,
            cta: schedule ? "Schedule" : "Continue",
            action,
            onSchedule: async (timestamp: number) => {
                $publishAt = new Date(timestamp);
                closeModal();
                // if (schedule) $view = "publish";
            }
        });
    }

    let imagesOfGroupsToPublish: string[] = [];

    $: {
        imagesOfGroupsToPublish = [];
        for (const groupId of $publishInGroups.keys()) {
            if ($groups[groupId]?.metadata?.picture) {
                imagesOfGroupsToPublish.push($groups[groupId].metadata.picture);
            }
        }
    }
</script>

<div class="flex flex-row items-centerw-full">
<div class="
    {$$props.class??""}
    flex flex-row items-center justify-between
    w-full
">
    <div class="flex flex-row flex-nowrap gap-2">
        {#if $mode !== 'edit'}
            <Tooltip.Root>
                <Tooltip.Trigger asChild let:builder>
                    <Button variant="outline" on:click={setMode('edit')}>
                        <CaretLeft class="md:mr-2" size={20} />
                        <span class="hidden md:block">Edit</span>
                    </Button>
                </Tooltip.Trigger>
                <Tooltip.Content>
                    Back to edit
                </Tooltip.Content>
            </Tooltip.Root>
        {/if}

        {#if $mode !== 'audience'}
            <Button variant="outline" on:click={setMode('audience')}>
                {#if imagesOfGroupsToPublish.length === 0}
                    <UsersThree class="md:mr-2" size={20} />
                {:else}
                    <div class="flex flex-row items-center rounded-full overflow-clip">
                        {#each imagesOfGroupsToPublish as image}
                            <img src={image} class="w-6 h-6 rounded-full" />
                        {/each}
                    </div>
                {/if}
                
                {#if $publishInGroups.size > 0}
                    {#each $publishInGroups.keys() as groupId}
                        {#if $groups[groupId]}
                            {$groups[groupId]?.metadata?.name??""}
                        {/if}
                    {/each}
                {:else}
                    <span class="hidden md:block">Audience</span>
                {/if}
            </Button>
        {/if}

        {#if $mode !== 'preview'}
            <Tooltip.Root>
                <Tooltip.Trigger asChild let:builder>
                    <Button variant="outline" on:click={setMode('preview')}>
                        <Eye class="md:mr-2" size={20} />
                        <span class="hidden md:block">Preview</span>
                    </Button>
                </Tooltip.Trigger>
                <Tooltip.Content>
                    Preview
                </Tooltip.Content>
            </Tooltip.Root>
        {/if}

        <ToggleDark />
        
    </div>

    <div class="flex flex-row flex-nowrap gap-2">
        <Tooltip.Root>
            <Tooltip.Trigger asChild let:builder>
                <Button size="icon" variant="outline" on:click={schedule}>
                    <Timer size={24} />
                </Button>
            </Tooltip.Trigger>
            <Tooltip.Content>
                Choose a time to schedule
            </Tooltip.Content>
        </Tooltip.Root>
        <Button on:click={onPublish} disabled={$publishing} variant="accent">
            {#if $publishing}
                <span class="loading loading-sm"></span>
            {/if}
            
            {#if $publishAt}
                <Timer weight="fill" />
                <span class="hidden md:block">
                    Schedule
                </span>
            {:else}
                <PaperPlaneTilt size={24} />
                <span class="hidden md:block">
                    Publish
                </span>
            {/if}
        </Button>
    </div>
</div>

<Button on:click={closeClicked} variant="secondary" class="rounded-full flex-none flex-col hidden md:flex">
    {#if !closing}
        <X size={20} />
    {:else}
        Confirm
    {/if}
</Button>

</div>