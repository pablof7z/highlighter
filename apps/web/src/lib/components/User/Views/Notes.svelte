<script lang="ts">
	import StoreFeed from "$components/Feed/StoreFeed.svelte";
	import { layout } from "$stores/layout";
    import { ndk } from "$stores/ndk";
	import { NDKKind, NDKUser } from "@nostr-dev-kit/ndk";
	import { getContext } from "svelte";

    export let user: NDKUser = getContext("user") as NDKUser;

    $layout.fullWidth = false;

    const notes = $ndk.storeSubscribe([
        { kinds: [ NDKKind.Text ], authors: [ user.pubkey ] },
    ], { groupable: false })
</script>

<div class="responsive-padding">
    <StoreFeed
        feed={notes}
        renderLimit={1}
    />
</div>
