<script lang="ts">
    import * as Feed from '$components/Feed';
	import { getContext } from 'svelte';
	import { Readable } from 'svelte/store';
    import { NDKVideo } from "@nostr-dev-kit/ndk";

    const userVideos = getContext('userVideos') as Readable<NDKVideo[]>;
</script>

<div class="responsive-padding">
    <Feed.Videos
        store={userVideos}
        skipAuthor
    />
</div>