<script lang="ts">
	import { goto } from "$app/navigation";
    import OptionsList from "$components/OptionsList.svelte";
    import { getUserHighlights, getUserSupporters, getGAUserContent, getUserCurations, getUserContent } from "$stores/user-view";
	import { user } from "@kind0/ui-common";
	import { Hexpubkey } from "@nostr-dev-kit/ndk";

    export let value: string = "Publications";
    export let name: string = "this user"
    export let authorUrl: string;
    export let pubkey: Hexpubkey;

    const highlights = getUserHighlights();
    const gaContent = getGAUserContent();
    const userContent = getUserContent();
    const curations = getUserCurations();

    let options: any = [];

    let hasCurations = false;
    let hasHighlights = false;
    let hasPublications = false;

    $: {
        options = [];

        if (!hasPublications && ($gaContent.length > 0 || $userContent.length > 0)) { hasPublications = true; }
        if (!hasCurations && $curations.length > 0) { hasCurations = true; }
        if (!hasHighlights && $highlights.length > 0) { hasHighlights = true; }
        if (hasBackstage)
            options.push({ name: "Backstage", tooltip: `Backstage content by ${name}`, class: 'gradient' },)
        if (hasBackstage)
            options.push({ name: "Chat", tooltip: `${name}'s Chat'`, class: 'gradient', href: `${authorUrl}/chat` },)
        if (hasPublications)
            options.push({ name: "Publications", tooltip: `Publications by ${name}` },)
        if (hasCurations)
            options.push({ name: "Curations", tooltip: `Curations created by ${name}` },)
        if (hasHighlights)
            options.push({ name: "Highlights", tooltip: `Highlights made by ${name}` },)

        options.push({ name: "Supporters", tooltip: `Supporters of ${name}` })
    }

    let hasBackstage = false;
    let currentUserSubscriberTier: string | true | undefined;
    const supporters = getUserSupporters();
    $: if ($user) {
        currentUserSubscriberTier = ($user && $supporters[$user.pubkey]) || undefined;
        hasBackstage = !!currentUserSubscriberTier || $user.pubkey === pubkey;
    }

    function changed(e: CustomEvent) {
        const {value} = e.detail;
        if (value === 'Chat') {
            goto(`${authorUrl}/chat`);
        }
    }
</script>

<OptionsList {options} bind:value on:changed={changed} />
