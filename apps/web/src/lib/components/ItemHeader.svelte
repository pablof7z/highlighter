<script lang="ts">
	import { NDKArticle, NDKUserProfile, NDKVideo } from '@nostr-dev-kit/ndk';
	import { Navbar, NavbarBackLink } from 'konsta/svelte';
	import { appMobileView } from '$stores/app';
	import ItemHeaderInner from './ItemHeaderInner.svelte';
	import { toggleBookmarkedEvent } from '$lib/events/bookmark';
	import { Repeat, Export, Lightning, TextAa } from 'phosphor-svelte';
	import { openModal } from 'svelte-modals';
	import AnimatedToggleButton from './PageElements/AnimatedToggleButton.svelte';
	import BookmarkButton from './buttons/BookmarkButton.svelte';
	import UserProfile from './User/UserProfile.svelte';
	import ShareModal from '$modals/ShareModal.svelte';
	import { Button } from './ui/button';
	import ToggleDark from './buttons/ToggleDark.svelte';
	import { userGenericCuration } from '$stores/session';
	import HorizontalOptionsList from './HorizontalOptionsList.svelte';
	import { NavigationOption } from '../../app';
	import { layout } from '$stores/layout';

    export let item: NDKArticle | NDKVideo;
    export let isFullVersion: boolean | undefined = undefined;
    export let urlPrefix: string;
    export let editUrl: string | undefined = undefined;
    export let title: string | undefined = undefined;
    export let compact = false;

    let userProfile: NDKUserProfile;

    let bookmarked: boolean;
    $: bookmarked = $userGenericCuration.has(item.tagId());
</script>

{#if item}
    {#if $appMobileView}
        <UserProfile bind:userProfile user={item.author} />
        <ItemHeaderInner {item} {isFullVersion} {urlPrefix} {editUrl} {title} />
    {:else}
        <div class="
            py-2 flex flex-col sm:flex-row gap-6 justify-between items-center w-full {$$props.containerClass??""} {$$props.class??""}
        ">
            <ItemHeaderInner {item} {isFullVersion} {urlPrefix} {editUrl} {title} />
        </div>
    {/if}
{/if}