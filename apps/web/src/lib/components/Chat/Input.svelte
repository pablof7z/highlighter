<script lang="ts">
	import ContentEditor from "$components/Forms/ContentEditor.svelte";
	import Name from "$components/User/Name.svelte";
	import { ndk } from "$stores/ndk";
	import { NDKEvent, NDKKind, NDKPublishError, NDKRelay, NDKRelaySet, NDKSimpleGroup, type NDKTag, type NostrEvent } from "@nostr-dev-kit/ndk";
	import { EventContent } from "@nostr-dev-kit/ndk-svelte-components";
	import { PaperPlaneTilt } from "phosphor-svelte";
	import { toast } from "svelte-sonner";

    export let relaySet: NDKRelaySet | undefined = undefined;
    export let event: NDKEvent | undefined = undefined;
    export let tags: NDKTag[] = [];
    export let kind: NDKKind;
    export let placeholder: string = "Type a message";
    export let showReplyingTo: boolean | undefined = undefined;
    export let replyTo: NDKEvent | undefined = undefined;

    export let content = '';
    let publishing = false;

    let resetAt = new Date();

    async function submit() {
        content = content.trim();
        if (content.length === 0) return;

        publishing = true;
        event ??= new NDKEvent($ndk, {
            content,
            kind,
            tags,
        } as NostrEvent)

        if (replyTo) event.tag(replyTo, "reply")

        console.log('publish to', relaySet)
        event.publish(relaySet)
        .then((e) => {
            event = undefined;
        })
        .catch((e: NDKPublishError) => {
            toast.error(e.relayErrors ?? "Error");
            content = event.content;
            console.error(e);
        });
        replyTo = undefined;
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

<div class="flex flex-row justify-stretch w-full">
    {#key resetAt}
        <div class="flex flex-col w-full">
            {#if showReplyingTo !== false && replyTo}
                {#key replyTo?.pubkey}
                    <button
                        class="responsive-padding text-left max-w-[calc(70dvw)]"
                        on:click={() => replyTo = undefined}
                    >
                        <span class="text-xs text-accent">Replying to <Name pubkey={replyTo.pubkey} /></span>
                        <div class="bg-secondary text-secondary-foreground text-sm truncate border-l-2 border-accent pl-2 py-2">
                            <EventContent ndk={$ndk} event={replyTo} />
                        </div>
                    </button>
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
                        text-lg h-full outline-none !bg-transparent px-2 placeholder::!px-4
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
            <button class="px-2 w-10 h-10" on:click={submit}>
                <PaperPlaneTilt weight="fill" class="text-accent w-full h-full" />
            </button>
        {/if}
    </div>
</div>
