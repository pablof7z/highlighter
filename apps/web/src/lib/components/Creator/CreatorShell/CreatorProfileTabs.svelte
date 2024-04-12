<script lang="ts">
	import { goto } from "$app/navigation";
	import { page } from "$app/stores";
    import OptionsList from "$components/OptionsList.svelte";
	import SubscribeButton from "$components/buttons/SubscribeButton.svelte";
	import HighlightIcon from "$icons/HighlightIcon.svelte";
    import { getUserHighlights, getUserSupporters, getGAUserContent, getUserCurations, getUserContent, getUserSubscriptionTiersStore } from "$stores/user-view";
	import { NDKUser } from "@nostr-dev-kit/ndk";
	import { Article, Atom, Gear, ListPlus, Note, Notepad, Ticket, UsersThree } from "phosphor-svelte";
	import SidebarPublishButton from "./SidebarPublishButton.svelte";
    import currentUser from "$stores/currentUser";
	import { openModal } from "svelte-modals";
	import BecomeSupporterModal from "$modals/BecomeSupporterModal.svelte";
	import SignupModal from "$modals/SignupModal.svelte";
	import { UserProfileType } from "../../../../app";

    export let value: string = "Publications";
    export let userProfile: UserProfileType | undefined = undefined;
    export let authorUrl: string;
    export let user: NDKUser;
    export let skipSubscribeButton = false;

    const highlights = getUserHighlights();
    const gaContent = getGAUserContent();
    const userContent = getUserContent();
    const curations = getUserCurations();
    const tiers = getUserSubscriptionTiersStore();

    let options: any = [];

    let hasCurations = false;
    let hasHighlights = false;
    let hasPublications = false;

    function url(path: string) {
        return `${authorUrl}${path}`;
    }

    function openBackstageModal() {
        if ($currentUser) {
            openModal(BecomeSupporterModal, { user });
        } else {
            openModal(SignupModal);
        }
    }

    $: {
        options = [];

        if (!hasPublications && ($gaContent.length > 0 || $userContent.length > 0)) { hasPublications = true; }
        if (!hasCurations && $curations.length > 0) { hasCurations = true; }
        if (!hasHighlights && $highlights.length > 0) { hasHighlights = true; }
        if (hasBackstage) {
            options.push({ name: "Backstage", href: url('/backstage'), class: 'gradient', icon: Ticket, premiumOnly: true },)
            options.push({ name: "Community", href: url('/posts'), class: 'gradient', icon: UsersThree, premiumOnly: true },)
        } else if ($tiers && $tiers.length > 0) {
            options.push({ name: "Backstage", icon: Ticket, fn: openBackstageModal, premiumOnly: true },)
            options.push({ name: "Community", icon: UsersThree, fn: openBackstageModal, premiumOnly: true },)
        }
        // if (hasBackstage)
        //     options.push({ name: "Chat", tooltip: `${name}'s Chat'`, class: 'gradient', href: `${authorUrl}/chat` },)
        options.push({ name: "Notes", href: url('/notes'), icon: Notepad },)
        if (hasPublications)
            options.push({ name: "Publications", href: authorUrl, icon: Article },)
        if (hasCurations)
            options.push({ name: "Curations", href: url('/curations'), icon: ListPlus },)
        if (hasHighlights)
            options.push({ name: "Highlights", href: url('/highlights'), icon: HighlightIcon },)

        options.push({ name: "Supporters", href: url('/supporters'), icon: Atom})

        if (user.pubkey === $currentUser?.pubkey) {
            options.push({ name: '-------', id: 1} )
            options.push({
                id: 'publish-button',
                component: {
                    component: SidebarPublishButton
                }
            })
            options.push({ name: '-------', id: 2} )
            options.push({
                name: 'Settings', href: '/settings', icon: Gear
            })
        } else if (!skipSubscribeButton) {
            options.push({
                id: 'subscribe-button',
                component: {
                    component: SubscribeButton,
                    props: {
                        user,
                        userProfile,
                        buttonClass: "w-full"
                    }
                }
            })
        }
    }

    $: for (const option of options) {
            if (option.href === $page.url.pathname) {
                value = option.name;
            }
        }

    let hasBackstage = false;
    let currentUserSubscriberTier: string | true | undefined;
    const supporters = getUserSupporters();
    $: if ($supporters && $currentUser) {
        currentUserSubscriberTier = ($currentUser && $supporters[$currentUser.pubkey]) || undefined;
        hasBackstage = !!currentUserSubscriberTier || $currentUser.pubkey === user.pubkey;
    }

    function changed(e: CustomEvent) {
        const {value} = e.detail;
        if (value === 'Chat') {
            goto(`${authorUrl}/chat`);
        }
    }
</script>

<OptionsList {options} bind:value on:changed={changed} class="sm:flex-col w-full max-sm:gap-2 gap-4" />
