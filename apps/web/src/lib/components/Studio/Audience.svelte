<script lang="ts">
	import Checkbox from "$components/Forms/Checkbox.svelte";
    import { getRelayListForUser, NDKArticle, NDKEvent, NDKList, NDKRelayList, NDKRelaySet, NDKSimpleGroup, NDKSubscriptionTier, NDKTag } from "@nostr-dev-kit/ndk";
	import { getContext, onMount } from "svelte";
	import { Writable, Readable, get, derived } from "svelte/store";
    import * as Groups from "$components/Groups";
	import { ndk } from "$stores/ndk";
	import currentUser from "$stores/currentUser";
	import { PublishInGroupStore, PublishInTierStore, Scope, Types } from ".";
	import { Globe, Star, Timer } from "phosphor-svelte";
	import { Button } from "$components/ui/button";
    import * as Tabs from "$lib/components/ui/tabs/index.js";
    import * as Card from "$lib/components/ui/card/index.js";
	import { groups } from '$stores/groups';

	// import MakePublicAfter from "$components/Editor/Audience/MakePublicAfter.svelte";
    
    export let type: Writable<Types>;
    
    export let publishInGroups: PublishInGroupStore;
    export let preview: Readable<NDKArticle | NDKEvent | undefined>;
    export let withPreview: Writable<boolean>;

    export let publishInTiers: PublishInTierStore;

    const event = getContext("event") as Writable<NDKArticle>;
    export let publishScope: Writable<Scope>;

    let selectedGroups: Record<string, boolean | NDKSubscriptionTier[]> = {};
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
        if (!group) continue;
        if (selectedGroups[groupId]) {
            publishInGroups.update(v => {
                v.set(groupId, group.relayUrls);
                return v;
            });
        } else {
            publishInGroups.update(v => {
                v.delete(groupId);
                return v;
            });
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
</script>

<div class="flex flex-col gap-6 py-6 responsive-padding">
    <Card.Root>
        <Card.Header>
            <Card.Title>Audience Scope</Card.Title>
            <Card.Description>
                Select the audience for this post.
            </Card.Description>
        </Card.Header>
        
        <Card.Content>
            <Tabs.Root bind:value={$publishScope} class="w-full">
                <Tabs.List class="grid w-fit grid-cols-2 mb-6">
                    <Tabs.Trigger value="public">
                        <Globe class="w-5 h-5 mr-1.5" />
                        Public
                    </Tabs.Trigger>
                    <Tabs.Trigger value="private" class="!text-gold">
                        <Star class="w-5 h-5 mr-1.5" weight="fill" />
                        Private
                    </Tabs.Trigger>
                </Tabs.List>
                <Tabs.Content value="public">
                    <div class="rounded border px-4 py-2 text-muted-foreground lg:text-sm bg-secondary">
                        This post will be
                        <span class="text-foreground">
                            shared far-and-wide
                        </span>
                        to reach the largest possible audience.

                    </div>
                </Tabs.Content>

                <Tabs.Content value="private">
                    <div class="flex flex-col gap-6">
                        <div class="rounded border px-4 py-2 text-muted-foreground lg:text-sm bg-secondary">
                            This post will be accessible
                            <span class="text-foreground">only to community members</span>.
                        </div>
                    </div>
                </Tabs.Content>
            </Tabs.Root>
        </Card.Content>
    </Card.Root>

    {#if $groups && Object.keys($groups).length > 0}
        <Card.Root>
            <Card.Header>
                <Card.Title>
                    {#if $publishScope === 'public'}
                        Share in Communities
                    {:else}
                        Communities
                    {/if}
                </Card.Title>
                <Card.Description>
                    {#if $publishScope === 'public'}
                        Choose communities where to share this post.
                    {:else}
                        Choose communities whose members can view this post.
                    {/if}
                </Card.Description>
            </Card.Header>

            <Card.Content>
                <div class="border flex flex-col divide-y divide-border rounded">
                    <Groups.List groups={$groups} bind:selectedGroups {publishInTiers} scope={$publishScope} />
                </div>
            </Card.Content>
        </Card.Root>
    {/if}


    {#if $publishScope === 'private'}
    <Card.Root>
        <Card.Header>
            <Card.Title>Preview</Card.Title>
            <Card.Description>
                Allow non-subscribers to view a preview of this post.
            </Card.Description>
        </Card.Header>

        <Card.Content>
            <div class="border flex flex-col divide-y divide-border rounded">
                <Checkbox bind:value={$withPreview} class="p-3 border rounded">
                    <Globe class="w-10 h-10" slot="icon" />

                    <div class="flex flex-row gap-2 items-center">
                        
                        <div class="flex flex-col items-start gap-0 5">
                            <b class="text-lg">Public preview</b>
                            <div class="text-muted-foreground text-sm">
                                {#if $withPreview}
                                    Non-subscribers will see a preview of this post.
                                {:else}
                                    Non-subscribers will not know this post exists.
                                {/if}
                            </div>
                        </div>
                    </div>

                    <Button
                        variant="outline"
                        slot="button"
                        class="{ $withPreview ? "" : "hidden" }"
                    >
                        Edit Preview
                    </Button>
                </Checkbox>
            </div>
        </Card.Content>
    </Card.Root>
    {/if}

    <!-- {#if $publishScope === "private" && $withPreview && $event}
        <ArticlePreviewEditor article={$event} />
    {/if} -->
    
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