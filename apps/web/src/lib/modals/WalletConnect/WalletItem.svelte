<script lang="ts">
	import RadioButton from "$components/Forms/RadioButton.svelte";
	import { ndk } from "$stores/ndk";
	import { pluralize } from "$utils";
	import { NDKEvent, NDKKind } from "@nostr-dev-kit/ndk";

    export let event: NDKEvent;
    export let currentValue: string;

    const mintCount = event.getMatchingTags("mint").length;
    const name = event.tagValue("name") ?? event.dTag;

    const tokens = $ndk.storeSubscribe({ kinds: [NDKKind.CashuToken], ...event.filter() });
</script>

<RadioButton bind:currentValue value={`nip-60:${event.dTag}`}>
    Use {name}

    <div slot="description">
        Nostr wallet with {mintCount} {pluralize(mintCount, "mint")}
        {#if $tokens && $tokens.length > 0}
            and
            {$tokens.length} {pluralize($tokens.length, "token")}
        {/if}
    </div>
</RadioButton>