<script lang="ts">
	import Nip89ToolModal from '$modals/Nip89ToolModal.svelte';
    import ndk from '$stores/ndk';
	import { jobRequestKinds, kindToText } from '$utils';
	import { NDKAppHandlerEvent, NDKEvent, type NDKUserProfile } from "@nostr-dev-kit/ndk";
	import { Avatar, EventCardDropdownMenu, EventContent, Name } from '@nostr-dev-kit/ndk-svelte-components';
	import { Pencil } from 'phosphor-svelte';
	import { openModal } from 'svelte-modals';

    export let dvm: NDKEvent;

    /**
     * Event that should be referrenced in the card (if different than the app handler event)
     */
    export let event: NDKEvent | undefined = dvm;

    const user = dvm.author;
    const kTag = dvm.tagValue("k");
    let supportedKind: number;

    if (kTag) supportedKind = parseInt(kTag);

    let profile: NDKUserProfile | undefined;

    if (dvm.content) {
        try {
            profile = JSON.parse(dvm.content) as unknown as NDKUserProfile;
        } catch (e) {}
    }

    const profilePromise = new Promise((resolve) => {
        if (profile?.name && profile?.image) {
            resolve(profile);
        } else {
            user.fetchProfile().then(resolve);
        }
    });

    const kTags = dvm.getMatchingTags("k");

    function edit() {
        openModal(Nip89ToolModal, {
            nip89event: NDKAppHandlerEvent.from(event!)
        });
    }
</script>

{#await profilePromise then}
    <div class="flex flex-row gap-4 w-full card card-compact image-full md:!rounded-2xl overflow-hidden">
        <figure>
            <Avatar ndk={$ndk} userProfile={profile} {user} class="h-full bg-accent2" />
        </figure>
        <div class="card-body flex flex-col gap-4">
            <div class="flex flex-row gap-4 flex-grow">
                <div class="flex flex-col gap-2 whitespace-normal w-full">
                    <div class="flex flex-row justify-between dropdown dropdown-end">
                        <Name ndk={$ndk} userProfile={profile} {user} class="text-xl text-base-100-content truncate font-semibold" />
                        <EventCardDropdownMenu ndk={$ndk} {event}>
                            <li>
                                <button on:click={edit} class="flex flex-row items-center gap-3">
                                    <Pencil class="w-5 h-5" />
                                    Edit
                                </button>
                            </li>
                        </EventCardDropdownMenu>
                    </div>
                    <div class="text-base max-h-48 md:max-h-96 overflow-clip overflow-y-auto">
                        <EventContent
                            ndk={$ndk}
                            event={new NDKEvent(undefined, {
                                content: profile?.about||profile?.bio||"",
                                tags: []
                            })}
                        />
                    </div>
                </div>
            </div>

            {#if !$$slots.default}
                {#if kTags.length > 0}
                    <h3 class="text-base-100-content text-lg">Features</h3>
                    {#each dvm.getMatchingTags("k") as tag}
                        {#if jobRequestKinds.includes(parseInt(tag[1]))}
                            {kindToText(parseInt(tag[1]))}
                        {/if}
                    {/each}
                {/if}

                <a class="btn btn-accent glass" href="/dvms/{user.npub}">
                    View DVM
                </a>
            {:else}
                <slot />
            {/if}
        </div>
    </div>
{/await}

<style lang="postcss">
    :global(.event-card--dropdown-menu) {
        @apply dropdown-content;
        @apply bg-base-100 p-4 rounded-box;
    }

    :global(.event-card--dropdown-menu li) {
        @apply py-1;
    }

    :global(.event-card--dropdown-menu li svg) {
        @apply mr-2;
    }
</style>
