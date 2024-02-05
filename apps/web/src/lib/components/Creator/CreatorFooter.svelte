<script lang="ts">
	import CurrentSupporters from "$components/CurrentSupporters.svelte";
	import SubscribeButton from "$components/buttons/SubscribeButton.svelte";
    import { mainWrapperMargin, pageSidebar } from "$stores/layout";
    import type { Hexpubkey, NDKSubscriptionTier, NDKUser } from "@nostr-dev-kit/ndk";
	import type { Readable } from "svelte/store";

    export let user: NDKUser;
    export let tiers: Readable<NDKSubscriptionTier[]>;
    export let userSupporters: Readable<Record<Hexpubkey, string | undefined>>;

    let hasSidebar = false;
    $: hasSidebar = !!$pageSidebar?.component;
</script>

<div class="h-16">&nbsp;</div>

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
        <div>
            <CurrentSupporters
                supporters={$userSupporters}
                {user}
            />
        </div>

        <SubscribeButton {user} {tiers} />
    </div>
</div>