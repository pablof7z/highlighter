<script lang="ts">
	import VideoEditPage from "$components/Forms/VideoEditPage.svelte";
	import { ndk } from "@kind0/ui-common";
	import { NDKArticle } from "@nostr-dev-kit/ndk";

    let article = new NDKArticle($ndk);
</script>

<VideoEditPage {article} />
