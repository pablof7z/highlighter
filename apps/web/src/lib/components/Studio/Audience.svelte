<script lang="ts">
	import Checkbox from "$components/Forms/Checkbox.svelte";
    import { getRelayListForUser, NDKEvent, NDKRelayList, NDKSimpleGroup, NDKTag } from "@nostr-dev-kit/ndk";
	import { onMount } from "svelte";
	import { Writable, Readable, get } from "svelte/store";
    import * as Groups from "$components/Groups";
	import { group } from "console";
	import { ndk } from "$stores/ndk";
	import currentUser from "$stores/currentUser";
    import * as DropdownMenu from "$lib/components/ui/dropdown-menu/index.js";
    
    export let event: Writable<NDKEvent>;
    export let groups: Readable<Record<string, NDKSimpleGroup>>;

    let selectedGroups: Record<string, boolean> = {};
    let selectedRelays: Record<string, boolean> = {};

    onMount(() => {
        console.log($event.tags);
        for (const tag of $event.getMatchingTags("h")) {
            selectedGroups[tag[1]] = true;
        }
        selectedGroups = selectedGroups;
        console.log(selectedGroups);
    })

    function isNotHWithValue(value: string) {
        return (tag: NDKTag) => !(tag[0] === "h" && tag[1] === value);
    }

    $: if (selectedGroups) {
        // remove all h tags from $event and add the h tags that are true in selectedGroups
        for (const [id, selected] of Object.entries(selectedGroups)) {
            $event.tags = $event.tags.filter(isNotHWithValue(id));
            if (selected) {
                $event.tags.push(["h", id, ...$groups[id].relayUrls() as string[]]);
            }
        }

        // $event = $event;
    }

    let relays: string[] | undefined;
    $: if ($currentUser && relays === undefined) {
        relays = [];
        getRelayListForUser($currentUser.pubkey, $ndk).then((list: NDKRelayList) => {
            relays = list.relays
            for (const r of relays) {
                selectedRelays[r] = true;
            }
        });
    }
</script>

<div class="flex flex-col gap-6 py-6">
<section class="settings bg-secondary/30">
    <div class="field">
        <div class="title">Communities</div>
        <div class="description">
            Select the communities you want to share this post to.
        </div>

        <div class="border flex flex-col divide-y divide-border rounded">
            <Groups.List groups={$groups} bind:selectedGroups />
        </div>
    </div>
</section>
<!-- 
{#if relays && relays.length > 0}
    <section class="settings bg-secondary/30">
        <div class="field">
            <div class="title">Relays</div>
            <div class="description">
                Select the relays you want to share this post to.
            </div>

            <div class="border flex flex-col divide-y divide-border rounded">
                {#each relays as relay}
                    <Checkbox bind:value={selectedRelays[relay]} class="p-3">
                        <div class="flex flex-row gap-4 items-center">
                            <div class="flex flex-col items-start">
                                <b>{relay}</b>
                            </div>
                        </div>
                    </Checkbox>
                {/each}
            </div>
        </div>
    </section>
{/if} -->
</div>

{JSON.stringify($event.tags, null, 4)}