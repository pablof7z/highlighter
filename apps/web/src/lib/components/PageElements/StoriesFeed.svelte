<script lang="ts">
    import HorizontalList from "$components/PageElements/HorizontalList";
	import { Avatar } from "$components/ui/avatar";
	import StoryModal from "$modals/StoryModal.svelte";
	import { ndk } from "$stores/ndk";
	import { userFollows } from "$stores/session";
	import { wotFilteredStore } from "$stores/wot";
	import { openModal } from "$utils/modal";
	import { NDKKind } from "@nostr-dev-kit/ndk";
	import { derived } from "svelte/store";

    export let timeLimit = 1719227774; // 24 hours ago

    const videos = $ndk.storeSubscribe([
        { kinds: [1063], authors: Array.from($userFollows), limit: 100, "#m": ["video/mp4"], since: timeLimit },
        { kinds: [1063], limit: 100, "#m": ["video/mp4"], since: timeLimit },
        { kinds: [NDKKind.HorizontalVideo+1], limit: 100, since: timeLimit },
    ])
    
    const filteredVideos = derived(wotFilteredStore(videos), ($videos) => {
        return $videos.filter(video => video.tagValue("url"));
    });
    
    const pubkeysWithVideos = derived(filteredVideos, ($filteredVideos) => {
        return Array.from(new Set($filteredVideos.map(video => video.pubkey)))
            .map(pubkey => { return {id: pubkey, pubkey}; })
    });
</script>

<HorizontalList items={$pubkeysWithVideos} let:item>
    <button on:click={() => openModal(StoryModal, { pubkey: item.pubkey })} class="py-1">
        <Avatar pubkey={item.pubkey} class="w-14 h-14" ring />
    </button>
</HorizontalList>