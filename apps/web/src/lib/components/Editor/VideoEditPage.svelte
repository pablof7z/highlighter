<script lang="ts">
    import { NDKVideo } from "@nostr-dev-kit/ndk";
	import { getUserSubscriptionTiersStore } from "$stores/user-view";
	import VideoEditor from './VideoEditor.svelte';
	import Shell from "$components/PostEditor/Shell.svelte";
	import VideoMetaPage from "./VideoMetaPage.svelte";
	import VideoPreviewEditor from "$components/PostEditor/VideoPreviewEditor.svelte";
	import { nonSubscribersPreview, preview, selectedTiers, wideDistribution } from "$stores/post-editor";
	import UserProfile from "$components/User/UserProfile.svelte";
	import { user } from "@kind0/ui-common";

    export let video: NDKVideo;
    export let videoFile: File | undefined = undefined;
    export let teaser: NDKVideo;

    let tiers: Record<string, boolean> = { "Free": true };

    $preview = teaser;
    $nonSubscribersPreview = true;

    $: $wideDistribution = !!(
        $preview && ($preview as NDKVideo).url || $selectedTiers["Free"]?.selected
    )

    const allTiers = getUserSubscriptionTiersStore();

    $: for (const tier of $allTiers) {
        const dTag = tier.tagValue("d");
        if (dTag && tiers[dTag] === undefined) {
            tiers[dTag] = false;
        }
    }
</script>

<UserProfile user={$user} let:authorUrl>
    <Shell type="video" {video}>
        <VideoEditor bind:video bind:videoFile />
        <div slot="meta">
            <VideoMetaPage bind:video bind:videoFile />
        </div>
        <div slot="editPreview">
            <VideoPreviewEditor bind:video bind:teaser {authorUrl} />
        </div>
    </Shell>
</UserProfile>