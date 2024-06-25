<script lang="ts">
	import { page } from "$app/stores";
	import PageTitle from "$components/PageElements/PageTitle.svelte";
	import { Button } from "$components/ui/button";
	import ContentCreatorPrompt from "$modals/Mobile/ContentCreatorPrompt.svelte";
	import { layoutMode, pageHeader } from "$stores/layout";
	import { featuredCreatorsPerCategory } from "$utils/const";
	import { openModal } from "$utils/modal";
	import { Block, Navbar, Page, Toolbar } from "konsta/svelte";
	import { onMount } from "svelte";

    $layoutMode = "mobile-full-screen";
    let mode = $page.url.searchParams.get("mode") ?? "signup";

    $: $pageHeader = {
        left: { label: "back" },
        title: mode === "signup" ? "Welcome" : "Login",
        right: {},
    }

    let categories: string[] = [];

    function toggleCategory(category: string) {
        if (categories.includes(category)) {
            categories = categories.filter(c => c !== category)
        } else {
            categories = [...categories, category];
        }
    }

    onMount(() => {
        openModal(ContentCreatorPrompt);
    })
    
</script>

<Toolbar bottom class="fixed bottom-0 my-8 p-4 w-full flex flex-row items-center">
    <Button variant="link" on:click={() => openModal(ContentCreatorPrompt)}>
        Are you a content creator?
    </Button>

</Toolbar>

<Block class="flex flex-col grow">
    <PageTitle title="Pick your interests" />
    
    <div class="flex flex-row flex-wrap gap-6">
        {#each Object.entries(featuredCreatorsPerCategory) as [category, pubkeys]}
            <Button variant={categories.includes(category) ? "default" : "outline"} on:click={() => toggleCategory(category)}>
                {category}
            </Button>
        {/each}
    </div>
</Block>
