<script lang="ts">
	import { slide } from 'svelte/transition';
    import AvatarWithName from '$components/User/AvatarWithName.svelte';
	import { appHandlers, ndk } from "@kind0/ui-common";
	import { NDKKind, type NDKEvent, type NDKUserProfile } from "@nostr-dev-kit/ndk";
	import { CaretDown } from 'phosphor-svelte';
	import ServiceProviderItem from './ServiceProviderItem.svelte';
	import { userAppHandlers } from '$stores/session';

    export let eventId: string;
    export let title: string;
    export let kind: number;
    let profile: NDKUserProfile | undefined;

    $: {
        const appHandlerEvent = $userAppHandlers.get(kind);
        if (appHandlerEvent && appHandlerEvent.size > 0) {
            const e = appHandlerEvent.values().next().value;
            if (e) eventId = e;
        }

        $ndk.fetchEvent(eventId).then((e) => {
            if (e) {
                // event = e;
                profile = JSON.parse(e.content);
                if (profile) {
                    profile.image ??= profile.picture;
                }
            }
        });
    }

    let showProviders = false;
    let more = false;
    let loading = false;

    function toggleMore() {
        more = !more;
    }

    async function fetchProviders(): Promise<Set<NDKEvent>> {
        loading = true;

        return new Promise((resolve) => {
            $ndk.fetchEvents({kinds: [NDKKind.AppHandler], "#k": [kind.toString()]}).then(r => {
                console.log(r);
                if (r.size === 0) loading = false;
                resolve(r);
            }).catch(() => {
                loading = false;
            })
        })
    }

    function readyToDisplay() {
        loading = false;
    }
</script>

{#if profile}
    <div class="flex flex-col">
        <div class="w-full flex flex-row justify-between items-center">
            <div class="text-white/80 text-xs font-semibold tracking-widest uppercase">
                {title}
            </div>
            <button class="text-white text-opacity-30 text-sm font-normal leading-6" on:click={toggleMore}>What’s this?</button>
        </div>

        {#if more}
            <div class="border border-base-300 rounded-box p-4 text-sm my-4" transition:slide>
                <slot name="about" />
            </div>
        {/if}

        <div class="w-full text-left border-r border-l border-b border-base-300 rounded-box flex flex-col">
            <button
                class="
                    main
                    {showProviders && !loading ? '!rounded-b-none' : ''}
                "
                on:click={() => showProviders = !showProviders}
            >
                <AvatarWithName
                    userProfile={profile}
                    class="!items-start"
                    nameClass="font-medium text-white text-lg"
                    spacing="gap-4"
                >
                    <div class="text-sm text-neutral-500 text-left">
                        {profile.about}
                    </div>
                </AvatarWithName>

                {#if !loading}
                    <CaretDown class="w-4 h-4" />
                {:else}
                    <span class="loading"></span>
                {/if}
            </button>
        </div>

        {#if showProviders}
            {#await fetchProviders() then events}
                <ul class="border-2 border-base-300" class:hidden={loading}>
                    {#each events as event}
                        <ServiceProviderItem {event} {kind} on:ready={readyToDisplay} />
                    {/each}
                </ul>
            {/await}
        {/if}
    </div>
{/if}

<style lang="postcss">
    button.main {
        @apply flex flex-row justify-between gap-4 p-4 items-center bg-base-300 rounded-box;
    }

    button.main:hover {
        @apply bg-base-300/60;
    }
</style>