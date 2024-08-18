<script lang="ts">
	import { Button } from "$components/ui/button";
	import { getGroupUrl } from '$utils/url';
	import { GroupData } from '$components/Groups';
	import { ArrowRight } from 'phosphor-svelte';

    export let title: string;
    export let step: string;
    export let groupData: GroupData | undefined;

    title = ""
</script>

<div class="flex flex-col items-center gap-6">
    <h1>
        You're done!
    </h1>

    {#if step !== 'created'}
        <p>
            We're getting your publication ready.
        </p>

        <p class="text-muted-foreground text-sm">This should only take a few seconds.</p>
    {:else}
        <p>
            Your publication is ready to go!
        </p>
    {/if}

    {#if step === 'created' && groupData}
        <Button class="w-full" href={getGroupUrl(groupData)}>
            View your publication
            <ArrowRight class="ml-2" size={20} />
        </Button>
    {/if}
</div>