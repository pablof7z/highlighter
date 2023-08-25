<script lang="ts">
	import type { NDKEvent, NDKUser, NDKUserProfile } from "@nostr-dev-kit/ndk";
    import { Avatar, EventCardDropdownMenu, Name } from "@nostr-dev-kit/ndk-svelte-components";
	import ndk from "$stores/ndk";
	import { RelativeTime } from "@kind0/ui-common";

    export let event: NDKEvent;
    export let title: string | undefined = undefined;
    export let href: string | undefined = "#";
    export let user: NDKUser | undefined = event.author;
    export let userProfile: NDKUserProfile | undefined = undefined;
</script>

<div
    class="card card-compact group {$$props.class}"
    on:mouseover
    on:mouseleave
    on:mouseout
>
    <div class="card-body flex flex-col gap-3">
        <div class="card-title justify-between  items-start pb-2">
            {#if $$slots.header}
                <slot name="header" />
            {:else}
                <div class="flex flex-row items-center justify-between w-full">
                    <div class="flex flex-row items-center gap-2 font-normal text-sm text-base-100-content">
                        <Avatar ndk={$ndk} {user} {userProfile} class="w-8 h-8 rounded-full" />
                        <div class="flex flex-row items-center gap-1">
                            <span class="truncate max-w-xs inline-block">
                                <Name ndk={$ndk} {user} {userProfile} class="font-semibold" />
                            </span>
                        </div>
                    </div>
                </div>
            {/if}

            <div class="flex flex-row gap-2 dropdown dropdown-end text-sm font-normal">
                <EventCardDropdownMenu {event} />
                {#if !$$slots.headerRight}
                    <a {href}>
                        <RelativeTime
                            timestamp={event.created_at*1000}
                            class="text-sm whitespace-nowrap hidden md:block"
                        />
                    </a>
                {:else}
                    <slot name="headerRight" />
                {/if}
            </div>
        </div>


        <slot />
    </div>
</div>

<style lang="postcss">
    :global(.event-card--dropdown-menu) {
        @apply dropdown-content;
        @apply bg-base-100 p-4 rounded-box;
        @apply z-10
    }

    :global(.event-card--dropdown-menu li) {
        @apply py-1;
    }

    :global(.event-card--dropdown-menu li svg) {
        @apply mr-2;
    }
</style>
