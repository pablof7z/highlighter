<script lang="ts">
	import { mainWrapperMargin, pageSidebar } from "$stores/layout";
    import type { NDKUser } from "@nostr-dev-kit/ndk";

    export let user: NDKUser;

    let hasSidebar = false;
    $: hasSidebar = !!$pageSidebar?.component;
</script>

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

        <button class="button">
            Subscribe
        </button>
    </div>
</div>