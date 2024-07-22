<script lang="ts">
	import ContentEditor from "$components/Forms/ContentEditor.svelte";
	import Button from "$components/ui/button/button.svelte";
	import Name from "$components/User/Name.svelte";
	import { ndk } from "$stores/ndk";
	import { relaySetForEvent } from "$utils/event";
	import { NDKEvent, NDKKind, NDKPublishError, NDKRelay, NDKSimpleGroup, type NDKTag, type NostrEvent } from "@nostr-dev-kit/ndk";
	import { PaperPlaneTilt } from "phosphor-svelte";
	import { toast } from "svelte-sonner";

    export let group: NDKSimpleGroup | undefined = undefined;
    export let event: NDKEvent | undefined = undefined;
    export let tags: NDKTag[] = [];
    export let kind: NDKKind = NDKKind.GroupChat;
    export let placeholder: string = "Type a message";
    export let showReplyingTo: boolean = false;

    let relaySet = event ? relaySetForEvent(event) : undefined;

    export let content = '';
    let publishing = false;

    let resetAt = new Date();

    async function submit() {
        publishing = true;
        event ??= new NDKEvent($ndk, {
            content,
            kind,
            tags,
        } as NostrEvent)

        relaySet = group?.relaySet ?? relaySetForEvent(event);
        console.log('relaySet', Array.from(relaySet.relays)[0])

        event.publish(relaySet)
        .then((e) => {
            console.log("then", e);
            event = undefined;
        })
        .catch((e: NDKPublishError) => {
            toast.error(e.relayErrors ?? "Error");
            content = event.content;
            console.error(e);
        });
        content = '';
        resetAt = new Date();

        publishing = false;
    }

    async function onkeydown({detail: event}: CustomEvent<KeyboardEvent>) {
        if (event.key === 'Enter' && !event.shiftKey && !publishing && content.trim().length > 0) {
            event.preventDefault();
        }
    }
</script>

<div class="flex flex-row justify-stretch">
    {#key resetAt}
        <div class="flex flex-col w-full">
            {#if showReplyingTo && event}
                {#key event?.pubkey}
                    <span class="text-xs text-accent">Replying to <Name pubkey={event.pubkey} /></span>
                {/key}
            {/if}
            <div class="grow w-full border p-2 bg-background/50 rounded overflow-clip border-border">
                <ContentEditor
                    forceWywsiwyg
                    markdown={false}
                    toolbar={false}
                    autofocus={true}
                    bind:content
                    rows={1}
                    enterSubmits={true}
                    class="
                        !min-h-none w-full grow flex items-center justify-center overflow-hidden text-base {$$props.class??""}
                        text-lg h-full outline-none !bg-transparent
                    "
                    on:keydown={onkeydown}
                    on:submit={submit}
                    {placeholder}
                    captureTyping={true}
                />
            </div>
        </div>
    {/key}

    <div class="z-50 right-2 flex justify-end items-center bottom-0" class:hidden={!publishing && content.length === 0}>
        {#if publishing}
            <div class="loading loading-sm text-accent loading-bars"></div>
        {:else}
            <Button variant="accent" class="">
                <PaperPlaneTilt weight="fill" class="w-full h-full" />
            </Button>
        {/if}
    </div>
</div>
