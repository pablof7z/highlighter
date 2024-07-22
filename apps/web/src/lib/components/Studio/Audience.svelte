<script lang="ts">
	import Checkbox from "$components/Forms/Checkbox.svelte";
    import { getRelayListForUser, NDKEvent, NDKRelayList, NDKSimpleGroup, NDKTag } from "@nostr-dev-kit/ndk";
	import { onMount } from "svelte";
	import { Writable, Readable, get } from "svelte/store";
    import * as Groups from "$components/Groups";
	import { ndk } from "$stores/ndk";
	import currentUser from "$stores/currentUser";
	import { PublishInGroupStore } from ".";
    
    export let groups: Readable<Record<string, NDKSimpleGroup>>;
    export let publishInGroups: PublishInGroupStore;

    let selectedGroups: Record<string, boolean> = {};
    let selectedRelays: Record<string, boolean> = {};

    onMount(() => {
        for (const groupId of $publishInGroups.keys()) {
            selectedGroups[groupId] = true;
        }
        selectedGroups = selectedGroups;
        console.log(selectedGroups);
    })

    $: for (const groupId in selectedGroups) {
        const group = $groups[groupId];
        if (selectedGroups[groupId]) {
            $publishInGroups.set(groupId, group.relayUrls());
        } else {
            $publishInGroups.delete(groupId);
        }
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

    let widely = true;
</script>

<div class="flex flex-col gap-6 py-6">
    <!-- <div class="border flex flex-col divide-y divide-border rounded">
        <Checkbox bind:value={widely} class="p-3">
            <div class="flex flex-row gap-4 items-center">
                <Globe class="w-8 h-8" />
        
                <div class="flex flex-col items-start">
                    <b>Publicly accessible</b>
                </div>
            </div>
        </Checkbox>
    </div> -->
    
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