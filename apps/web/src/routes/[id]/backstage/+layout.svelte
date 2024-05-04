<script lang="ts">
	import { Users } from 'phosphor-svelte';
	import HorizontalOptionsList from './../../../lib/components/HorizontalOptionsList.svelte';
	import { ChatCenteredDots, TShirt } from 'phosphor-svelte';
	import { Ticket } from 'phosphor-svelte';
	import { House } from 'phosphor-svelte';
	import { page } from '$app/stores';
    import UserProfile from "$components/User/UserProfile.svelte";
	import { NavigationOption, UserProfileType } from '../../../app';
	import BackstageHeader from "$components/Backstage/BackstageHeader.svelte";
	import { layoutMode, layoutNavState, resetLayout } from '$stores/layout';
	import { onDestroy } from 'svelte';

    $layoutMode = "full-width";
    $layoutNavState = "collapsed";

    onDestroy(resetLayout);
    
    let { user } = $page.data;

    let userProfile: UserProfileType;
    let authorUrl: string;

    let options: NavigationOption[];

    let backstageUrl: string;
    let value = "";

    $: backstageUrl = `${authorUrl}/backstage`;

    $: options = [
        { name: "Backstage", href: `${backstageUrl}`, icon: Ticket },
        { name: "Forum", href: `${backstageUrl}/forum`, icon: Users },
        { name: "Chat", href: `${backstageUrl}/chat`, icon: ChatCenteredDots },
        // { name: "Goals", href: `${backstageUrl}/goals`, icon: CurrencyBtc },
        // { name: "Merch", href: `${backstageUrl}/merch`, icon: TShirt },
    ]
</script>

<UserProfile {user} bind:userProfile bind:authorUrl />

<div class="w-full lg:px-6 flex flex-col gap-6 max-w-7xl mx-auto">
    <div class="flex flex-col items-center">
        <BackstageHeader {user} {userProfile} />
        <div class="w-fit">
            <HorizontalOptionsList {options} bind:value />
        </div>
    </div>

    

    <slot />
</div>