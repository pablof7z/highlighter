<script lang="ts">
    import { Button } from "$components/ui/button";
	import { MagnifyingGlass, Plus } from "phosphor-svelte";
    import NewPost from '$components/Creator/NewPost.svelte';
	import Input from "$components/ui/input/input.svelte";
	import { goto } from "$app/navigation";
    import * as Footer from "$components/Footer";

    export let newPost = false;
    export let collapsed = true;
    export let placeholder: string | undefined = "Explore";
    export let value: string = "";

    function onkeydown(event: KeyboardEvent) {
        if (event.key === "Enter") {
            goto('/search?q=' + encodeURIComponent(value));
        }
    }
</script>

<Footer.Shell bind:collapsed>
    <Button
        variant="accent"
        class="rounded-full flex-none max-sm:w-12 w-10 max-sm:h-12 h-10 p-2"
        on:click={() => {
            newPost = !newPost;
            collapsed = false;
        }}
    >
        <Plus class="w-full h-full" weight="bold" />
    </Button>

    <div class="flex flex-row relative mx-2">
        <MagnifyingGlass class="absolute top-1/2 left-4 transform -translate-y-1/2" />
        <Input
            class="
                grow h-11 border border-border bg-background rounded-full !px-4 p-2 !text-lg
                placeholder:text-muted-foreground
                !pl-10
            "
            placeholder="Explore"
            bind:value
            on:keydown={onkeydown}
        />

    </div>

    <div slot="main">
        {#if newPost}
            <NewPost />
        {/if}
    </div>
</Footer.Shell>