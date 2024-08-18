<script lang="ts">
	import ModalShell from "$components/ModalShell.svelte";
    import * as Card from "$components/ui/card";
	import { Button } from "$components/ui/button";
	import { NavigationOption } from "../../../app";
	import { Writable } from "svelte/store";
    import * as Studio from '$components/Studio';
	import TagInput from "$components/Editor/TagInput.svelte";
	import AvatarWithName from "$components/User/AvatarWithName.svelte";
	import currentUser from "$stores/currentUser";
	import { closeModal, openModal } from "$utils/modal";
	import CoverImageModal from "$modals/CoverImageModal.svelte";
	import Textarea from "$components/ui/textarea/textarea.svelte";

    export let state: Writable<Studio.State<Studio.Type>>;
    export let actions: Studio.Actions;

    let event = Studio.getEventFromState($state);

    let actionButtons: NavigationOption[] = [];
    
    $: {
        actionButtons = [];

        const opt: NavigationOption = {
            buttonProps: { variant: 'default' },
            fn: () => {
                actions.publish()
                closeModal();
            },
        };
        
        if ($state.publishAt) opt.name = "Schedule";
        else opt.name = "Publish Now";
        actionButtons.push(opt);
    }

    let summary = event?.summary;
</script>

<ModalShell
    title="Publish"
    class="max-w-3xl w-full"
    {actionButtons}
>
    <div class="grid w-full">
        <div class="flex flex-col gap-2 min-h-[5rem] lg:min-h-[10rem] {$$props.class??""}">
            <div class="grid grid-cols-3 items-start gap-y-1 gap-x-4">
                <div class="col-span-2 flex flex-col">
                    <AvatarWithName user={$currentUser} avatarSize="xs" class="font-light !text-xs truncate" />
                    
                    <div class="flex flex-col gap-0 mt-2">
                        <h2 class="text-xl md:text-xl font-medium mb-0 max-sm:max-h-[3.5rem] overflow-y-clip">{event.title}</h2>
                        <Textarea bind:value={summary} class="w-full !outline-none text-base text-muted-foreground font-light" />
                    </div>
                </div>
        
                <button class="flex-none h-full flex flex-col" on:click={() => openModal(CoverImageModal, { article: event, onSave: (article) => event = article })}>
                    {#if event.image}
                        <img src={event.image} alt={event.title} class="w-full h-full object-cover sm:rounded-sm" />
                    {:else}
                        <div class="w-full h-full bg-gray-200 rounded-sm" />
                    {/if}
                    <div class="text-xs text-muted-foreground text-center">
                        Change cover image
                    </div>
                </button>
            </div>
        </div>

        {#if event}
            <h3>Add tags</h3>
            <TagInput bind:event />
        {/if}
    </div>
</ModalShell>