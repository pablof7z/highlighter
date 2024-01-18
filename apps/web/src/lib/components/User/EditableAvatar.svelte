<script lang="ts">
	import type { UserProfileType } from './../../../app.d.ts';
	import { Avatar, ndk, user as currentUser } from "@kind0/ui-common";
    import { NDKEvent, NDKSubscriptionCacheUsage, type NDKUser, type NDKUserProfile } from "@nostr-dev-kit/ndk";
	import ImageUploader from "$components/Forms/ImageUploader.svelte";

    export let user: NDKUser;
    export let userProfile: UserProfileType | undefined = undefined;
    export let fetching: boolean;

    async function uploaded(e: CustomEvent<{url: string}>) {
        const url = e.detail.url;
        if (!url) return;

        let event = await $ndk.fetchEvent({
            kinds: [0],
            authors: [$currentUser.pubkey],
        }, {
            cacheUsage: NDKSubscriptionCacheUsage.ONLY_RELAY
        });

        if (!event) {
            alert("Failed to fetch event");
            return;
        }

        try {
            const content = JSON.parse(event.content) as NDKUserProfile
            content.image = url;
            event.content = JSON.stringify(content);
            event.id = "";
            event.sig = "";
            await event.publish();
        } catch(e) {
            alert("Failed to parse event content");
            console.error(e, event.content);
            return;
        }
    }
</script>

<ImageUploader {user} {userProfile} {fetching} on:uploaded={uploaded} alwaysUseSlot={true}>
    <Avatar {userProfile} {user} class="{$$props.class??""}" {fetching} />
</ImageUploader>
<!--
<button class="group {$$props.class??""} relative border-none">
    <div class="absolute top-0 w-full transition-all duration-200 opacity-0 group-hover:opacity-100 flex items-center justify-center z-50 h-full bg-black/50 rounded-full">
        <Pen class="text-white/80 w-full h-full max-h-[32px]" />
    </div>
</button> -->