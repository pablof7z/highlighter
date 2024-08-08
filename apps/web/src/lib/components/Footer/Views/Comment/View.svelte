<script lang="ts">
	import { NDKEvent } from '@nostr-dev-kit/ndk';
	import ContentEditor from '$components/Forms/ContentEditor.svelte';
	import { Writable } from 'svelte/store';
	import { State } from '.';
    import * as Composer from '$components/Composer';

    export let event: NDKEvent;
    export let placeholder = "Reply...";
    export let onZapped = () => {};
    export let open: (view?: string | false) => void;
    export let stateStore: Writable<State>;

    // $: if (state && !$stateStore.state) {
    //     $stateStore.state = state;
    //     $stateStore.actions = actions;
    // }
</script>

<Composer.Root
    replyTo={event}
    kind={1}
    bind:state={$stateStore.state}
    bind:actions={$stateStore.actions}
    on:publish={(e) => {
    }}
>
    {#if $stateStore.state && $stateStore.actions}
        <Composer.Editor
            state={$stateStore.state}
            class="bg-background rounded p-4 w-full text-foreground"
            {placeholder}
        />
        <Composer.Attachments state={$stateStore.state} />
    {/if}
</Composer.Root>
<!-- 
<ContentEditor
    class="
        grow !min-h-[300px] border border-border bg-background rounded-xl px-4 p-2 text-lg
        placeholder:text-muted-foreground placeholder:!text-xs
    "
    {placeholder}
    allowMarkdown={false}
    toolbar={false}
    autofocus
    bind:content
/> -->
