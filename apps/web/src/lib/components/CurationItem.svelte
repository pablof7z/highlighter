<script lang="ts">
	import type { NDKList } from "@nostr-dev-kit/ndk";
	import UserProfile from "./User/UserProfile.svelte";
	import AvatarWithName from "./User/AvatarWithName.svelte";
	import ItemLink from "./Events/ItemLink.svelte";

    export let list: NDKList;

    const image = list.tagValue("image");
    let authorUrl: string;

    const durationTag = `${list.items.length} items`;
</script>

<ItemLink
    event={list}
    {durationTag}
    image={list.image}
    title={list.title}
    grid={true}
/>

<!-- <div class="card w-full">
    {#if image}
        <figure class="card-image">
            <img src={image} alt="" />
        </figure>
    {/if}

    <div class="card-body">
        <h3 class="title">
            <a href="{authorUrl}/{list.dTag}">{list.title}</a>
        </h3>
        <AvatarWithName
            user={list.author}
            avatarSize="tiny"
            nameClass="text-sm text-neutral-500"
            bind:authorUrl
        />
    </div>
</div>

<style>
    h3.title {
        @apply text-white text-xl font-semibold;
    }
</style> -->