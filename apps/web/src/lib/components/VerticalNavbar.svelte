<script lang="ts">
	import { page } from "$app/stores";
	import { userTiers } from "$stores/session";
	import { Compass, Tray, PaperPlane, ChatCircle, House, Funnel, Fire, User } from "phosphor-svelte";
    import { user } from "@kind0/ui-common";
	import { openModal } from "svelte-modals";
	import CurrentUser from "./CurrentUser.svelte";
	import VerticalNavbarItem from "./VerticalNavbarItem.svelte";
    import NewItemModal from '$modals/NewItemModal.svelte';
	import HighlightIcon from "$icons/HighlightIcon.svelte";
</script>

<div class="
    justify-between items-stretch inline-flex fixed border-r border-base-300 flex-col h-full mobile-nav !bg-base-100 mobile-nav
    sm:w-20 w-full
    max-sm:btm-nav max-sm:btm-nav-lg
    z-50
">
    <div class="
        sm:pt-6
        flex max-sm:flex-row sm:flex-col justify-start items-center gap-3 flex-nowrap
    ">
        <div class="
            items-center flex flex-nowrap
            sm:flex-col
            justify-between sm:justify-start
            w-full
            gap-4
        ">
            <CurrentUser />

            <VerticalNavbarItem href="/home" tooltip="Home" let:active>
                <House class="w-full h-full" weight={active ? "fill" : "regular"} />
            </VerticalNavbarItem>

            <VerticalNavbarItem href="/explore" tooltip="Explore" let:active>
                <Fire class="w-full h-full" weight={active ? "fill" : "regular"} />
            </VerticalNavbarItem>

            <VerticalNavbarItem href="/inbox" tooltip="Inbox" let:active>
                <Tray class="w-full h-full" weight={active ? "fill" : "regular"} />
            </VerticalNavbarItem>

            <VerticalNavbarItem href="/highlights" tooltip="Highlights" let:active>
                <HighlightIcon class="w-full h-full" weight={active ? "fill" : "regular"} />
            </VerticalNavbarItem>

            <VerticalNavbarItem href="/chat" tooltip="Chat" let:active>
                <ChatCircle class="w-full h-full" weight={active ? "fill" : "regular"} />
            </VerticalNavbarItem>
            {#if $user && $userTiers && $userTiers.length > 0}
                <VerticalNavbarItem tooltip="Create something new" let:active on:click={() => openModal(NewItemModal)}>
                    <PaperPlane class="w-full h-full" weight={active ? "fill" : "regular"} />
                </VerticalNavbarItem>
            {:else if $user}
                <VerticalNavbarItem tooltip="Start publishing on Nostr" href="/welcome/creators">
                    <PaperPlane class="w-full h-full" weight="fill" />
                </VerticalNavbarItem>
            {/if}
        </div>
    </div>
</div>

<style>
    div {
        /* @apply border; */
    }

    .btm-nav > a, .btm-nav > button, .btm-nav > label {
        @apply py-2;
    }

    .btm-nav > a > span, .btm-nav > button > span, .btm-nav > label > span{
        @apply btm-nav-label text-xs hidden;
    }
</style>