<script lang="ts">
	import { OpenFn } from "$components/Footer";
	import Button from "$components/ui/button/button.svelte";
	import Name from "$components/User/Name.svelte";
	import { NDKArticle } from "@nostr-dev-kit/ndk";
	import { Check } from "phosphor-svelte";
    import { scrollPercentage } from "$stores/layout";

    export let open: OpenFn;
    export let article: NDKArticle;
    export let mainView: string | undefined;

    $: if ($scrollPercentage < 50 && mainView === 'zap-prompt') {
        open(false);
    }
</script>

<div class="flex flex-col lg:flex-row gap-4 lg:gap-0 lg:items-center w-full justify-between">
    <div class="text-foreground">
        You've reached the end of the article. Would you like to reward
        <Name class="text-gold" pubkey={article.pubkey} /> for their work?
    </div>

    <div class="flex flex-row gap-2">
        <Button variant="gold" on:click={() => {
            open('zap')
        }}>
            <Check size={24} class="mr-2" />
            Yes!
        </Button>

        <Button variant="secondary" on:click={() => open(false)}>
            No, thanks
        </Button>
    </div>
</div>