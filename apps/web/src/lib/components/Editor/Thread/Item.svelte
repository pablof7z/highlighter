<script lang="ts">
	import { NDKHighlight, NDKUserProfile } from "@nostr-dev-kit/ndk";
	import ContentEditor from "$components/Forms/ContentEditor.svelte";
	import Attachments from "$components/Feed/NewPost/Attachments.svelte";
	import LengthIndicator from "$components/LengthIndicator.svelte";
    import { createEventDispatcher } from "svelte";
	import { StackPlus, X } from "phosphor-svelte";
	import { ThreadItem } from "$utils/thread";
	import currentUser from "$stores/currentUser";
	import { EventContent } from "@nostr-dev-kit/ndk-svelte-components";
	import { openModal } from "$utils/modal";
	import SelectHighlight from "$modals/SelectHighlight.svelte";
	import Avatar from "$components/User/Avatar.svelte";
	import Name from "$components/User/Name.svelte";
	import RelativeTime from "$components/PageElements/RelativeTime.svelte";
	import { ndk } from "$stores/ndk";

    const dispatch = createEventDispatcher();

    export let item: ThreadItem;
    export let userProfile: NDKUserProfile | undefined = undefined;
    export let shouldDisplayVerticalBar: boolean;
    export let autofocus = false;
    export let content = item.event.content;
    export let urls = item.urls;
    export let readOnly = false;
    let hasFocus = false;
    let resetEditorAt = new Date();

    function selectHighlight() {
        openModal(SelectHighlight, {
            onSelect: (highlight: NDKHighlight) => {
                content += `nostr:${highlight.encode()}`
                resetEditorAt = new Date();
            }
        });
    }

    const title = item.event.tagValue("title");

    const threadView = true;
    const shouldExpandBeyondBox = true;

    let confirmRemove = false;

    function remove() {
        if (item.event.content.length < 2 || confirmRemove) {
            dispatch("remove");
        } else {
            confirmRemove = true;
            setTimeout(() => confirmRemove = false, 3000);
        }
    }

    function contentChanged() {
        dispatch("contentChanged", content);
    }
</script>

<div class="flex flex-row items-start w-full group">
    <!-- Avatars -->
    <div class="flex flex-col items-center flex-none w-10 sm:w-16 self-stretch">
        <Avatar user={$currentUser} {userProfile} class="w-8 sm:w-12 h-8 sm:h-12 object-cover" type="circle" />
        {#if shouldDisplayVerticalBar}
            <div class="
                w-[1px] min-h-[40px] bg-foreground/40 grow
                {shouldExpandBeyondBox && "-mb-[40px]"}
            "></div>
        {/if}
    </div>

    <!-- Content -->
    <div class="flex flex-col overflow-x-clip pl-2 md:pl-4 relative grow">
        <!-- Title and time -->
        <div class="flex flex-row items-start w-full gap-2 relative">
            <div class="flex flex-col items-start grow">
                {#if title && !threadView}
                    <div class="text-lg text-foreground font-semibold truncate grow">{title}</div>
                {/if}
                <div class="text-sm opacity-80">
                    <Name npubMaxLength={12} {userProfile} />
                </div>
            </div>

            <div class="justify-self-end text-sm h-full absolute right-0">
                <div class="flex flex-row items-center justify-end gap-2 place-self-end">
                    {#if readOnly}
                        <RelativeTime timestamp={new Date().getTime()+10000} />
                    {:else}
                        <div class="flex flex-row items-center gap-4">
                            <LengthIndicator
                                text={item.event.content}
                                overText=""
                            />

                            <button
                                class="
                                    rounded p-2 z-50 font-normal text-foreground group-hover:!opacity-100
                                    {confirmRemove ? "!bg-error/80" : "btn-neutral"}
                                "
                                class:btn-circle={!confirmRemove}
                                class:opacity-20={!hasFocus && !confirmRemove}
                                on:click={remove}>
                                {#if confirmRemove}
                                    Confirm?
                                {:else}
                                    <X size={16} />
                                {/if}
                            </button>
                        </div>
                    {/if}
                </div>
            </div>
        </div>

        <!-- Content / reactions / comment count -->
        <div class="flex flex-col items-stretch justify-stretch basis-0 shrink overflow-x-clip">
            {#if !readOnly}
                <div class="">
                    {#key resetEditorAt}
                        <ContentEditor
                            bind:content
                            on:focus={() => hasFocus = true}
                            on:blur={() => hasFocus = false}
                            on:submit
                            on:contentChanged={contentChanged}
                            toolbar={false}
                            placeholder="Write something"
                            {autofocus}
                            allowMarkdown={false}
                            class="sm:min-h-[5rem] px-0 text-lg"
                        />

                        <div class="flex flex-row items-center justify-between mt-10 mb-2">
                            <div class="flex flex-row gap-2 items-center justify-stretch transition-all duration-300 group-hover:!opacity-100" class:opacity-20={!hasFocus}>
                                <button class="btn btn-ghost btn-circle" on:click={selectHighlight}>
                                    <StackPlus size={24} />
                                </button>
                                <Attachments buttonClass="btn btn-ghost btn-circle btn-sm !py-1 text-zinc-300" bind:uploadedFiles={urls} />
                            </div>
                        </div>
                    {/key}
                </div>
            {:else}
                <Name npubMaxLength={12} {userProfile} user={$currentUser} class="text-sm mb-4" />
                <div class="text-foreground min-h-[4rem]">
                    <EventContent ndk={$ndk} event={item.event} />
                </div>
            {/if}
        </div>
    </div>
</div>