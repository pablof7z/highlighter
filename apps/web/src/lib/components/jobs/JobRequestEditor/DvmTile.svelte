<script lang="ts">
    import ndk from '$stores/ndk';
	import type { NDKAppHandlerEvent } from '@nostr-dev-kit/ndk';
	import { Avatar, Name } from '@nostr-dev-kit/ndk-svelte-components';
    import { createEventDispatcher } from 'svelte';

    export let dvm: NDKAppHandlerEvent;
    export let selected = false;

    const dispatch = createEventDispatcher();

    function click() {
        selected = !selected;
        dispatch('selectionchanged', {selected});
    }
</script>

{#await dvm?.fetchProfile()}
{:then profile}
    <button class="
        card card-compact h-64 !rounded-2xl overflow-clip
        border-spacing-8 p-1.5 border-4 !bg-cover image-full
        {selected ? 'border-accent' : 'border-transparent'}
    " on:click={click}
    >
        <figure>
            <Avatar ndk={$ndk} userProfile={profile} class="w-full" />
        </figure>
        <div class="card-body flex flex-row gap-4 whitespace-normal">
            <div class="flex flex-row gap-4">
                <div class="flex flex-col gap-2 whitespace-normal">
                    <div class="flex flex-row gap-2 items-center w-full justify-between">
                        <Name ndk={$ndk} userProfile={profile} class="text-xl text-base-100-content truncate" />
                    </div>
                    <span class="text-sm whitespace-normal text-left">{profile?.about||profile?.bio||""}</span>

                    <slot />
                </div>
            </div>
        </div>
    </button>
{:catch e}
        {e}
{/await}