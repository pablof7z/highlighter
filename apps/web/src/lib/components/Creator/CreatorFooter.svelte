<script lang="ts">
	import SubscribeButton from "$components/buttons/SubscribeButton.svelte";
    import { mainWrapperMargin, pageSidebar } from "$stores/layout";
    import type { NDKArticle, NDKUser } from "@nostr-dev-kit/ndk";
	import type { Readable } from "svelte/store";

    export let user: NDKUser;
    export let tiers: Readable<NDKArticle[]>;

    let hasSidebar = false;
    $: hasSidebar = !!$pageSidebar?.component;
</script>

tiers = {tiers}

<div class="
    fixed bottom-0
    max-sm:left-0
    right-0
    {hasSidebar ? "lg:left-96" : "sm:left-20"}
    h-16 mobile-nav
    flex items-center justify-between
    border-t border-white/20
">
    <div class="
        {$mainWrapperMargin}
        w-full
        flex items-center justify-between
    ">
        <div></div>

        <SubscribeButton {user} {tiers} />
    </div>
</div>