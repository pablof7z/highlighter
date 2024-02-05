<script lang="ts">
	import { Avatar, ndk, user as currentUser, UploadButton } from "@kind0/ui-common";
    import { NDKEvent, NDKSubscriptionCacheUsage, type NDKTag, type NDKUser, type NDKUserProfile } from "@nostr-dev-kit/ndk";
    import { createEventDispatcher } from 'svelte';

    export let url: string | undefined = undefined;

    const dispatch = createEventDispatcher();

    function uploadedImage(e: CustomEvent<{url: string, tags: NDKTag[]}>) {
        url = e.detail.url;

        dispatch('uploaded', url);
    }
</script>

<UploadButton type="image" on:uploaded={uploadedImage}>
    {#if url}
        <img src={url} class="object-cover {$$props.class??"w-12 h-12 flex-none rounded-full"}" />
    {:else}
        <div class="input-background w-12 h-12 {$$props.class??"rounded-full"}"></div>
    {/if}
</UploadButton>

<!-- <ImageUploader url={userProfile?.image} {user} {userProfile} {fetching} on:uploaded={uploaded} alwaysUseSlot={true}>
    <Avatar {userProfile} {user} class="{$$props.class??""}" {fetching} />
</ImageUploader> -->
<!--
<button class="group {$$props.class??""} relative border-none">
    <div class="absolute top-0 w-full transition-all duration-200 opacity-0 group-hover:opacity-100 flex items-center justify-center z-50 h-full bg-black/50 rounded-full">
        <Pen class="text-white/80 w-full h-full max-h-[32px]" />
    </div>
</button> -->