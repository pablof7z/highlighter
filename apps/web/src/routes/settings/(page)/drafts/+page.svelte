<script lang="ts">
	import { goto } from "$app/navigation";
	import Checkbox from "$components/Forms/Checkbox.svelte";
	import { Button } from "$components/ui/button";
	import Input from "$components/ui/input/input.svelte";
    import { layout } from "$stores/layout";
	import { publishDraftsToRelays } from "$stores/settings";
	import { getDefaultRelaySet } from "$utils/ndk";

    $layout = {
        title: "Drafts",
        back: { url: '/settings' }
    };

    let enabled = $publishDraftsToRelays !== false;

    if (enabled && (!Array.isArray($publishDraftsToRelays) || $publishDraftsToRelays.length === 0)) {
        $publishDraftsToRelays = getDefaultRelaySet().relayUrls;
    }

    let relays: string[] = $publishDraftsToRelays ? $publishDraftsToRelays : getDefaultRelaySet().relayUrls;

    function save() {
        goto("/settings");
    }
</script>

    <Checkbox
        bind:value={enabled}
    >
        Save drafts encrypted on relays
        <span class="text-sm" slot="description">
            When manually saving a draft, a copy will be encrypted and stored in relays; this makes your drafts
            more resilient and available in other devices and apps.
        </span>
    </Checkbox>

    {#if enabled && Array.isArray($publishDraftsToRelays)}
        <section class="my-10">
            <h1>Relays</h1>
            <h3>These are the relays where drafts will be stored, encrypted.</h3>
    
        
            {#each relays as relay, i}
                <Input bind:value={relays[i]} />
            {/each}

        <div class="flex flex-row items-center gap-4 mt-6">
            <Button size="lg" on:click={save}>
                Save
            </Button>
        
            <Button variant="outline" class="w-fit px-6" on:click={() => {
                relays = [...relays, ""];
            }}>
                Add New Server
            </Button>
        </div>
    </section>
{/if}

<style lang="postcss">
    h1 {
        @apply text-2xl font-semibold text-foreground;
        @apply mb-4;
    }

    h2 {
        @apply text-lg font-semibold;
        @apply mb-2;
    }

    section {
        @apply mb-6;
    }
</style>