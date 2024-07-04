<script lang="ts">
	import FooterShell from "./FooterShell.svelte";
    import { Button } from "$components/ui/button";
    import ContentEditor from '$components/Forms/ContentEditor.svelte';
	import { Plus } from "phosphor-svelte";
    import NewPost from '$components/Creator/NewPost.svelte';

    export let newPost = false;
    export let collapsed = true;
</script>

<FooterShell bind:collapsed>
    <Button
        variant="accent"
        class="rounded-full flex-none w-9 h-9 p-0"
        on:click={() => {
            newPost = !newPost;
            collapsed = false;
        }}
    >
        <Plus class="w-4 h-4" weight="bold" />
    </Button>

    <ContentEditor
        class="
            grow h-11 border border-border bg-background rounded-full px-4 p-2 !text-xs
            placeholder:text-muted-foreground placeholder:!text-xs
        "
        allowMarkdown={false}
        toolbar={false}
    />

    <div slot="main">
        {#if newPost}
            <NewPost />
        {/if}
    </div>
</FooterShell>