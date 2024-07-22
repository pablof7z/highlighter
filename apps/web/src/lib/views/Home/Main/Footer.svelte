<script lang="ts">
    import { Button } from "$components/ui/button";
	import { MagnifyingGlass, Plus } from "phosphor-svelte";
    import NewPost from '$components/Creator/NewPost.svelte';
	import Input from "$components/ui/input/input.svelte";
	import { goto } from "$app/navigation";
    import * as Footer from "$components/Footer";

    import NewItem from "$components/Footer/Views/NewItem";

    export let collapsed = true;
    export let placeholder: string | undefined = "Explore";
    export let value: string = "";
    export let mainView: string;

    function onkeydown(event: KeyboardEvent) {
        if (event.key === "Enter") {
            goto('/search?q=' + encodeURIComponent(value));
        }
    }

    let collapse: () => void;

    function close() {
        collapse();
    }
</script>

<Footer.Shell
    bind:mainView
    bind:collapse
    buttons={[
        NewItem
    ]}
>
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
        {#if mainView === "newPost"}
            <NewPost on:close={close} />
        {/if}
    </div>
</Footer.Shell>