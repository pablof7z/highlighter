<script lang="ts">
	import { MagnifyingGlass, Plus } from "phosphor-svelte";
    import NewPost from '$components/Creator/NewPost.svelte';
	import Input from "$components/ui/input/input.svelte";
	import { goto } from "$app/navigation";
    import * as Footer from "$components/Footer";

    import NewItem from "$components/Footer/Views/NewItem";
	import Search from "$views/Search.svelte";

    export let placeholder: string | undefined = "Explore";
    export let value: string = "";
    let mainView: string = 'search';

    function onkeydown(event: KeyboardEvent) {
        if (event.key === "Enter") {
            goto('/search?q=' + encodeURIComponent(value));
        }
    }

    function close() {
        open(false);
    }

    let open: Footer.OpenFn;

    let buttons: Footer.ButtonView[] = [];

    $: if (mainView === 'search') {
        buttons = [];
    } else {
        buttons = [
            NewItem
        ];
    }
    
</script>

<Footer.Shell
    bind:mainView
    bind:open
    hideCollapsedView={mainView === 'search'}
    {buttons}
>
    <div class="flex flex-row relative mx-2">
        <MagnifyingGlass class="absolute top-1/2 left-4 transform -translate-y-1/2" />
        <Input
            class="
                grow h-11 border border-border bg-background/50 rounded-full !px-4 p-2 !text-lg
                placeholder:text-muted-foreground
                !pl-10
            "
            placeholder="Explore"
            bind:value
            on:keydown={onkeydown}
            on:focus={() => open('search')}
        />
    </div>

    <div slot="main">
        {#if mainView === "newPost"}
            <NewPost on:close={close} />
        {:else if mainView === 'search'}
            <div class="h-[50dvh] bg-black/50 border rounded overflow-y-auto scrollbar-hide">
                <Search
                    placeholder="Explore"
                    bind:value
                    containerClass="px-2"
                    inputClass="grow h-11 bg-transparent rounded-full !pr-4 p-2 !text-lg
                        rounded-b-none shadow-none !outline-0
                        placeholder:text-muted-foreground
                        "
                />
            </div>
        {/if}
    </div>
</Footer.Shell>