<script lang="ts">
	import ReaderButton from './../../components/Event/Article/ReaderButton.svelte';
	import Zap from "$components/Events/Zaps/Zap.svelte";
    import ContentEditor from "$components/Forms/ContentEditor.svelte";
	import FooterShell from "$components/PageElements/Mobile/FooterShell.svelte";
	import { Button } from "$components/ui/button";
    import { NDKArticle } from "@nostr-dev-kit/ndk";
	import { Check, Lightning } from "phosphor-svelte";
	import Tts from '$components/Actions/TTS/TTS.svelte';

    export let article: NDKArticle;
    export let mainView: 'zap' | 'tts' | "content" | undefined = undefined;
    export let collapsed = true;
    export let placeholder = "Reply";

    $: collapsed = mainView === undefined;

    let zapped = false;
    function onZapped() {
        mainView = undefined;
        collapsed = true;
        zapped = true;
        setTimeout(() => zapped = false, 2000);
    }

    let content = "";

    function cancelContentEditor() {
        mainView = undefined;
        content = "";
    }

    function publishContentEditor() {
        mainView = undefined;
        console.log(content);
        content = "";
    }
</script>

<FooterShell
    bind:collapsed
    bind:mainView
>
    {#if collapsed}
        <Button
            variant={zapped ? undefined : "accent"}
            class="
                flex-none w-[38px] h-[38px] p-0
                rounded
                {zapped ? 'bg-green-500' : ''}
            "
            on:click={() => {
                mainView = 'zap';
            }}
        >
            {#if !zapped}
                <Lightning class="w-4 h-4" weight="fill" />
            {:else}
                <Check class="w-4 h-4" weight="bold" />
            {/if}
        </Button>

        <ReaderButton
            {article}
            variant="outline"
            class="rounded w-[38px] h-[38px] p-0 flex-none"
            onShow={() => mainView = 'tts' }
        />

        <ContentEditor
            class="
                grow h-11 border border-border bg-background rounded px-4 p-2 !text-sm
                placeholder:text-muted-foreground placeholder:!text-xs scrollbar-hide

            "
            {placeholder}
            allowMarkdown={false}
            on:focus={() => { mainView = "content" }}
            toolbar={false}
            bind:content
        />
    {:else if mainView === "content"}
        <div class="flex flex-row justify-between w-full">
            <Button variant="outline" on:click={cancelContentEditor}>
                Cancel
            </Button>

            <Button variant="accent" on:click={publishContentEditor}>
                Publish
            </Button>
        </div>
    {/if}

    <div slot="main">
        {#if mainView === 'content'}
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
            />
        {:else if mainView === 'zap'}
            <Zap
                event={article}
                on:zap={onZapped}
            />
        {:else if mainView === 'tts'}
            <Tts event={article} />
        {/if}
    </div>
</FooterShell>