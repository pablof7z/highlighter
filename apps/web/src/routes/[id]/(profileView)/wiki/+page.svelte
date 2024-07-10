<script lang="ts">
    import * as Feed from '$components/Feed';
	import { getContext } from 'svelte';
	import { Readable } from 'svelte/store';
    import { NDKWiki } from "@nostr-dev-kit/ndk";

    const userWiki = getContext('userWiki') as Readable<NDKWiki[]>;
</script>

<Feed.Wiki
    store={userWiki}
/>