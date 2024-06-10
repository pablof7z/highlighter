<script lang="ts">
	import { NDKArticle, NDKVideo } from '@nostr-dev-kit/ndk';
    import AvatarWithName from '$components/User/AvatarWithName.svelte';
    import { Headphones, TextAlignLeft } from 'phosphor-svelte';
	import SubscribeButton from './buttons/SubscribeButton.svelte';
	import ClientName from './ClientName.svelte';
	import currentUser from '$stores/currentUser';

    export let item: NDKArticle | NDKVideo;
    export let isFullVersion: boolean | undefined = undefined;
    export let urlPrefix: string;
    export let editUrl: string | undefined = undefined;
    export let title: string | undefined = undefined;

    $: console.log('itemheader', item?.id)

    const author = item?.author;

    const isVideo = item instanceof NDKVideo;
    const isArticle = item instanceof NDKArticle;
</script>

{#if item}
<div class="py-2 flex flex-col sm:flex-row gap-6 justify-between items-center w-full {$$props.containerClass??""} {$$props.class??""}">
    <div class="flex flex-row gap-6 items-center max-sm:justify-between w-full">
        <AvatarWithName user={author} spacing="gap-4" avatarType="square" class="text-foreground grow">
            <ClientName event={item} />
        </AvatarWithName>
        <div class="flex flex-row items-center">
            {#if item.pubkey === $currentUser?.pubkey && editUrl}
                <div class="flex flex-row gap-4">
                    <a href={editUrl} class="button-black px-6 mr-4">Edit</a>
                </div>
            {/if}

            <SubscribeButton user={item.author} />
        </div>
    </div>

    {#if isFullVersion === false}
        <SubscribeButton user={author} />
    {:else if false}
        {#if isVideo}
            <div class="tooltip tooltip-left max-sm:hidden" data-tip="Coming soon">
                <button class="btn btn-neutral !rounded-full">
                    <TextAlignLeft size={24} />
                    Transcript
                </button>
            </div>
        {:else if isArticle}
            <div class="tooltip tooltip-left max-sm:hidden" data-tip="Coming soon">
                <button class="btn btn-neutral !rounded-full">
                    <Headphones size={24} />
                    Listen
                </button>
            </div>
        {/if}
    {/if}
</div>
{/if}