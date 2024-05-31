<script lang="ts">
	import ItemFooter from '$components/Event/ItemView/ItemFooter.svelte';
	import UserProfile from '$components/User/UserProfile.svelte';
	import { pageHeader } from "$stores/layout";
	import { urlFromEvent } from '$utils/url';
	import { NDKEvent } from "@nostr-dev-kit/ndk";
	import { CaretLeft } from 'phosphor-svelte';

    export let event: NDKEvent;
    export let title: string | undefined = undefined;

    let authorUrl: string;
    let urlPrefix: string;

    $: urlPrefix = urlFromEvent(event, authorUrl);

    $pageHeader ??= {};
    
    $: {
        $pageHeader.title = title;
        $pageHeader.left = {
            url: urlPrefix,
            label: title ?? "Back",
            icon: CaretLeft
        } 
        $pageHeader.footer = {
            component: ItemFooter,
            props: { event, urlPrefix }
        }
    }
</script>

<UserProfile user={event.author} bind:authorUrl />

<slot />
