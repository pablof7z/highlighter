<script lang="ts">
    import OptionsList from "$components/OptionsList.svelte";
    import { getUserHighlights, getUserSupporters, getGAUserContent, getUserCurations, getUserContent } from "$stores/user-view";
	import { user } from "@kind0/ui-common";

    export let value: string = "Publications";
    export let name: string = "this user"

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
        if (hasPublications)
            options.push({ name: "Publications", tooltip: `Publications by ${name}` },)
        if (hasCurations)
            options.push({ name: "Curations", tooltip: `Curations created by ${name}` },)
        if (hasHighlights)
            options.push({ name: "Highlights", tooltip: `Highlights made by ${name}` },)

        options.push({ name: "Supporters", tooltip: `Supporters of ${name}` })
    }

    let hasBackstage = false;
    let currentUserSubscriberTier: string | undefined;
    const supporters = getUserSupporters();
    $: currentUserSubscriberTier = ($user && $supporters[$user.pubkey]) || undefined;
</script>

<OptionsList {options} bind:value />
