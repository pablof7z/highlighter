<script lang="ts">
	import PageTitle from "$components/PageElements/PageTitle.svelte";
	import { Button } from "$components/ui/button";
	import { Input } from "$components/ui/input";
	import { pageHeader } from "$stores/layout";
    import { createEventDispatcher } from "svelte";

    const dispatcher = createEventDispatcher();

    function skip() {

    }

    $pageHeader ??= {};
    $pageHeader.right = {
        label: "Skip",
        fn: skip
    }

    let name: string;
</script>

<div class="flex flex-col items-start justify-center w-4/5">
    <PageTitle title="Welcome" />
    
    <label class="mb-2">
        What should people call you?
    </label>

    <Input type="text" bind:value={name} class="w-full text-center text-lg" autofocus placeholder="Name" />

    <div class="self-end w-full py-10 flex flex-col-reverse gap-4 responsive-padding">
        <Button variant="outline" on:click={() => dispatcher('login')}>
            I already have a nostr account
        </Button>

        <Button class="w-full col-span-2">
            Create account
        </Button>
    </div>
</div>