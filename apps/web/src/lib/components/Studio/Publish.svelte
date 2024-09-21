<script lang="ts">
	import CoverImageModal from '$modals/CoverImageModal.svelte';
	import { Textarea } from '$components/ui/textarea';
    import * as Audience from "$components/Audience";
    import { writable, type Writable } from "svelte/store";
    import * as Studio from '$components/Studio';
    import * as Card from "$components/ui/card";
	import Checkbox from "$components/Forms/Checkbox.svelte";
	import { Globe, PaperPlaneRight, PaperPlaneTilt, Timer } from "phosphor-svelte";
	import TagInput from "$components/Editor/TagInput.svelte";
	import { slide } from "svelte/transition";
	import { openModal } from '$utils/modal';
	import { Button } from '$components/ui/button';

    export let state: Writable<Studio.State<Studio.Type>>;
        
    const audienceState = writable<Audience.State>($state.audience);
    $: $state.audience = $audienceState;

    let event = Studio.getEventFromState($state);
    let summary = event?.summary;
</script>

<div class="my-10 flex flex-col">
    <Card.Root class="my-5">
        <Card.Header>
            <Card.Title>
                This post is for...
            </Card.Title>
        </Card.Header>
        <Card.Content>
            <Audience.List state={audienceState} />
        </Card.Content> 
    </Card.Root>

    {#if $state.audience.scope === 'private'}
        <div transition:slide class="my-5">
            <Checkbox bind:value={$state.withPreview} class="p-3 border rounded">
                <Globe class="w-10 h-10" slot="icon" />

                <div class="flex flex-row gap-2 items-center">
                    
                    <div class="flex flex-col items-start gap-0 5">
                        <b class="text-lg">Public preview</b>
                        <div class="text-muted-foreground text-sm">
                            {#if $state.withPreview}
                                Non-members will see a preview of this post.
                            {:else}
                                Non-members will not know this post exists.
                            {/if}
                        </div>
                    </div>
                </div>

                <!-- <Button
                    variant="outline"
                    slot="button"
                    class="{ $state.withPreview ? "" : "hidden" }"
                >
                    Edit Preview
                </Button> -->
            </Checkbox>
        </div>
    {/if}

    {#if event}
        <Card.Root class="my-5">
            <Card.Header>
                <Card.Title>
                    Preview
                </Card.Title>
            </Card.Header>
            <Card.Content>
                <div class="flex flex-col gap-2 min-h-[5rem] lg:min-h-[10rem] {$$props.class??""}">
                    <div class="grid grid-cols-3 items-start gap-y-1 gap-x-4">
                        <div class="col-span-2 flex flex-col">
                            <div class="flex flex-col gap-0">
                                <h2 class="text-xl md:text-xl font-medium mb-0 max-sm:max-h-[3.5rem] overflow-y-clip">{event.title}</h2>
                                <Textarea bind:value={summary} class="w-full !outline-none text-base text-muted-foreground font-light resize-none border-none p-0 rounded-none focus:!outline-0" />
                            </div>
                        </div>
                
                        <button class="flex-none h-full flex flex-col" on:click={() => openModal(CoverImageModal, { article: event, onSave: (article) => event = article })}>
                            {#if event.image}
                                <img src={event.image} alt={event.title} class="w-full h-full object-cover sm:rounded-sm" />
                            {:else}
                                <div class="w-full h-full bg-secondary rounded-sm" />
                            {/if}
                            <div class="text-xs text-muted-foreground text-center w-full">
                                Change cover image
                            </div>
                        </button>
                    </div>

                    <h3>Tags</h3>
                    <TagInput bind:event />
                </div>
            </Card.Content> 
        </Card.Root>
    {/if}

    <div class="flex justify-end w-full">
        <Button size="lg" on:click={() => $state.mode = 'publishing'}>
            {#if !$state.publishAt}
                Publish
                <PaperPlaneRight size={20} class="ml-2" weight="fill" />
            {:else}
                Schedule
                <Timer size={20} class="ml-2" weight="fill" />
            {/if}
        </Button>
    </div>
</div>