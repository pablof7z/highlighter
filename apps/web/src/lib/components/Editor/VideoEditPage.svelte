<script lang="ts">
    import { NDKVideo } from "@nostr-dev-kit/ndk";
	import VideoEditor from './VideoEditor.svelte';
	import Shell from "$components/PostEditor/Shell.svelte";
	import VideoMetaPage from "./VideoMetaPage.svelte";
	import VideoPreviewEditor from "$components/PostEditor/VideoPreviewEditor.svelte";
	import { preview, previewContentChanged, previewTitleChanged, view } from "$stores/post-editor";
	import UserProfile from "$components/User/UserProfile.svelte";
	import { user } from "@kind0/ui-common";

    export let video: NDKVideo;
    export let videoFile: File | undefined = undefined;
    export let teaser: NDKVideo;

    $preview = teaser;

    $: if ($view !== "edit-preview" && $preview instanceof NDKVideo) {
        $preview.thumbnail = video.thumbnail;
        $preview.tags.push(...video.getMatchingTags("t"))
        if (!$previewTitleChanged) $preview.title = video.title;
        if (!$previewContentChanged) $preview.content = video.content;
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