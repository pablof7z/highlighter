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

    export let item: NDKArticle | NDKVideo;
    export let isFullVersion: boolean | undefined = undefined;
    export let urlPrefix: string;
    export let editUrl: string | undefined = undefined;
    export let title: string | undefined = undefined;
    export let compact = false;

    let userProfile: NDKUserProfile;

    let showTextTools = false;

    let bookmarked: boolean;
    $: bookmarked = $userGenericCuration.has(item.tagId());
</script>

{#if item}
    {#if $appMobileView}
        <UserProfile bind:userProfile user={item.author} />
        <Navbar
            title={compact ? title : undefined}
            subtitle={compact ? userProfile?.displayName : undefined}
            class="
                py-2 flex flex-col sm:flex-row justify-between items-center w-full {$$props.containerClass??""} {$$props.class??""}
            " subnavbarClass={!showTextTools ? "hidden" : ""}
            >
            <div class="flex flex-row items-center gap-2" slot="left">
                <NavbarBackLink showText={false} onClick={() => { window.history.back() }} />
                {#if compact}
                    <Button variant="link" on:click={(e) => { showTextTools = !showTextTools; } }>
                        <TextAa class="w-6 h-6" />
                    </Button>
                {/if}
            </div>
            {#if !compact}
                <div class="w-full">
                    <ItemHeaderInner {item} {isFullVersion} {urlPrefix} {editUrl} {title} />
                </div>
            {/if}

            <div class="flex flex-row items-center" slot="right" class:hidden={!compact}>
                {#if compact}
                    <AnimatedToggleButton
                        icon={Export}
                        buttonClass="hover:bg-yellow-400/20"
                        bgClass="bg-yellow-500"
                        iconClass={"text-yellow-400/30 group-hover:text-yellow-500 max-sm:text-yellow-500"}
                        on:click={() => openModal(ShareModal, { event: item })}
                    />

                    <BookmarkButton
                        on:click={() => toggleBookmarkedEvent(item)}
                        active={bookmarked}
                    />
                {/if}
            </div>
            
            <div class="w-full" slot="subnavbar">
                {#if showTextTools}
                    <div class="flex flex-row items-center gap-0">
                        <ToggleDark />
                    </div>
                {/if}
            </div>
        </Navbar>
    {:else}
        <div class="
            py-2 flex flex-col sm:flex-row gap-6 justify-between items-center w-full {$$props.containerClass??""} {$$props.class??""}
        ">
            <ItemHeaderInner {item} {isFullVersion} {urlPrefix} {editUrl} {title} />
        </div>
    {/if}
{/if}