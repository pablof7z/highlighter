<script lang="ts">
    import OptionsList from "$components/OptionsList.svelte";
    import { getUserHighlights } from "$stores/user-view";

    export let value: string = "Publications";
    export let name: string = "this user"

    const highlights = getUserHighlights();

    let options = [
        { name: "Publications" },
        { name: "Curations", tooltip: `Curations created by ${name}` },
        { name: "Supported Creators", tooltip: `Explore creators ${name} supports` }
    ];

    let hasHighlights = false;

    if (!hasHighlights && $highlights.length > 0) {
        hasHighlights = true;
        options.push({name: "Highlights", tooltip: `Highlights made by ${name}`})
    }
</script>

<OptionsList {options} bind:value />
