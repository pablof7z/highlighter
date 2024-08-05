<script lang="ts">
	import { Button } from "$components/ui/button";
	import { Input } from "$components/ui/input";
    import { createEventDispatcher } from "svelte";

    const dispatcher = createEventDispatcher();

    function skip() {

    }

    let name: string;
</script>

<div class="flex flex-col items-start justify-center w-4/5">
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