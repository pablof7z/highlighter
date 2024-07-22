<script lang="ts">
	import * as Footer from "$components/Footer";
    import { Button } from "$components/ui/button";
    import ContentEditor from '$components/Forms/ContentEditor.svelte';
	import { Plus } from "phosphor-svelte";
    import NewPost from '$components/Creator/NewPost.svelte';
	import { NDKSimpleGroup } from "@nostr-dev-kit/ndk";

    export let newPost = false;
    export let collapsed = true;
    export let placeholder: string | undefined = undefined;
    export let group: NDKSimpleGroup | undefined = undefined;
</script>

<Footer.Shell
    bind:collapsed
>
    <Button
        variant="accent"
        class="rounded-full flex-none w-12 h-12 p-2"
        on:click={() => {
            newPost = !newPost;
            collapsed = false;
        }}
    >
        <Plus class="w-full h-full" weight="bold" />
    </Button>

    <ContentEditor
        class="
            grow h-11 border border-border bg-background rounded-full px-4 p-2 !text-lg
            placeholder:text-muted-foreground placeholder:!text-lg
        "
        {placeholder}
        allowMarkdown={false}
        toolbar={false}
    />

    <div slot="main">
        {#if newPost}
            <NewPost />
        {/if}
    </div>
</Footer.Shell>