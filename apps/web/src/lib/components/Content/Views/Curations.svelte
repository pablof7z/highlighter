<script lang="ts">
    import { NDKList } from "@nostr-dev-kit/ndk";
	import { getContext } from "svelte";
	import { Readable } from "svelte/store";
    import * as Feed from "$components/Feed";

    const curations = getContext("curations") as Readable<NDKList[]>;
</script>

<Feed.Curations store={curations} />
