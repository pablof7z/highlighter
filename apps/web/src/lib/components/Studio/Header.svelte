<script lang="ts">
    import Button from "$components/ui/button/button.svelte";
	import { ArrowLeft, ArrowRight, CaretLeft, DotsThreeVertical, Eye, Moon, PaperPlaneTilt, PencilRuler, Star, Timer, UsersThree, X } from "phosphor-svelte";
	import { derived, writable, Writable } from "svelte/store";
    import * as Tooltip from "$lib/components/ui/tooltip";
	import { closeModal, openModal } from "$utils/modal";
	import ScheduleModal from "$modals/ScheduleModal.svelte";
	import ToggleDark from "$components/buttons/ToggleDark.svelte";
	import { goto } from "$app/navigation";
    import * as Draft from "$components/Draft";
    import * as Audience from "$components/Audience";
	import * as Studio from '$components/Studio';
    import * as DropdownMenu from "$components/ui/dropdown-menu";
	import { appMobileView } from "$stores/app";
	import { toggleMode } from "mode-watcher";

    export let state: Writable<Studio.State<Studio.Type>>;
    export let actions: Studio.Actions;

    function cont() {
        openModal(Studio.PrepublishModal, { state, actions })
    }
    
    function closeClicked() {
        goto("/studio");
    }

    function setMode(m: Studio.Mode) {
        return () => { $state.mode = m; }
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
                $state.publishAt = new Date(timestamp);
                closeModal();
                // if (schedule) $view = "publish";
            }
        });
    }

    const audienceState = writable<Audience.State>($state.audience);
    $: $state.audience = $audienceState;
</script>

<div class="
    {$$props.class??""}
    flex flex-row items-center justify-between
    w-full px-4 py-3
">
    <div class="flex flex-row items-center gap-4">
        <Button on:click={closeClicked} variant="secondary" class="flex-none flex-col hidden md:flex h-10 w-10">
            <ArrowLeft size={20} />
        </Button>

        {#if !$appMobileView}
            <ToggleDark variant="secondary" />
        {/if}

        <Draft.Button timer={30} save={actions.saveDraft} class="max-sm:hidden" />
    </div>

    <div class="flex flex-row flex-nowrap gap-2 grow lg:max-w-[var(--content-focused-width)] mx-auto lg:px-0">
        {#if $state.mode !== 'edit'}
            <Tooltip.Root>
                <Tooltip.Trigger asChild let:builder>
                    <Button variant="outline" on:click={setMode('edit')}>
                        <CaretLeft class="mr-2" size={20} />
                        Edit
                    </Button>
                </Tooltip.Trigger>
                <Tooltip.Content>
                    Back to edit
                </Tooltip.Content>
            </Tooltip.Root>
        {:else}
            <Audience.Button variant={$appMobileView ? "secondary" : "outline"} state={audienceState} />

            {#if !$appMobileView}
                <Tooltip.Root>
                    <Tooltip.Trigger asChild let:builder>
                        <Button variant="outline" on:click={setMode('preview')}>
                            <Eye class="mr-2" size={20} />
                            Preview
                        </Button>
                    </Tooltip.Trigger>
                    <Tooltip.Content>
                        Preview
                    </Tooltip.Content>
                </Tooltip.Root>
            {/if}
        {/if}
    </div>

    <div class="flex flex-row flex-nowrap gap-2">
        {#if !$appMobileView}
            {#if $state.mode === 'edit'}
                
            {/if}
        
            <Tooltip.Root>
                <Tooltip.Trigger>
                    <Button size="icon" variant="outline" on:click={() => schedule()}>
                        <Timer size={24} />
                    </Button>
                </Tooltip.Trigger>
                <Tooltip.Content>
                    Choose a time to schedule
                </Tooltip.Content>
            </Tooltip.Root>
        {:else}
            <DropdownMenu.Root>
                <DropdownMenu.Trigger>
                    <Button size="icon" variant="secondary">
                        <DotsThreeVertical size={24} />
                    </Button>
                </DropdownMenu.Trigger>
                <DropdownMenu.Content>
                <DropdownMenu.Group>
                    <DropdownMenu.Item on:click={setMode('preview')}>
                        <Eye class="mr-2" size={20} /> Preview
                    </DropdownMenu.Item>
                    <DropdownMenu.Item on:click={toggleMode}>
                        <Moon size={20} class="mr-2" />
                        Toggle light/dark
                    </DropdownMenu.Item>
                    <DropdownMenu.Item on:click={() => schedule()}>
                        <Timer size={24} class="mr-2" /> Schedule
                    </DropdownMenu.Item>
                </DropdownMenu.Group>
                </DropdownMenu.Content>
            </DropdownMenu.Root>
        {/if}
        <Button on:click={cont}>
            Continue
            <ArrowRight size={20} />
        </Button>
    </div>
</div>