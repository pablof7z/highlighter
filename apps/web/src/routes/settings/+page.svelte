<script lang="ts">
    import { page } from "$app/stores";
    import { layout } from "$stores/layout";
	import ToggleDark from '$components/buttons/ToggleDark.svelte';
	import AvatarWithName from '$components/User/AvatarWithName.svelte';
	import currentUser from '$stores/currentUser';
	import { ndk } from '$stores/ndk';
	import { logout } from '$utils/login';
	import { NDKPrivateKeySigner } from '@nostr-dev-kit/ndk';
	import { Key, CaretRight, ShareNetwork, Bell, Keyhole, Package, Code } from 'phosphor-svelte';
	import { Button } from "$components/ui/button";
	import FailedPublishesIndicator from "$components/FailedPublishesIndicator.svelte";
    let id: string;

    $: id = $page.url.search?.substring(1);

    $layout = {
        title: 'Profile',
        navigation: false,
        sidebar: false,
        fullWidth: false,
    }

    let authorUrl: string;
</script>

<svelte:head>
    <title>Settings</title>
</svelte:head>

<div class="responsive-padding">
{#if $currentUser}
    <AvatarWithName user={$currentUser} bind:authorUrl nameClass="text-xl text-foreground font-semibold"
        spacing="gap-4"
        avatarSize="large" avatarClass="w-16 h-16"
    />

    <div class="flex max-sm :flex-col flex-row gap-4 items-stretch w-full mb-10">
        <Button href={authorUrl} variant="outline">
            View Profile
        </Button>
        <Button href="/settings/profile" variant="outline">
            Edit Profile
        </Button>
        <Button variant="outline" on:click={logout}>
            Log out
        </Button>
    </div>

    <section class="w-full text-muted-foreground">
        <div class="uppercase tracking-wider">
            Account
        </div>

        <ul class="w-full">
            {#if $ndk.signer instanceof NDKPrivateKeySigner}
                <li>
                    <a href="/settings/keys">
                        <span>
                            <Key class="w-5 h-5" />
                            Keys
                        </span>
                        <CaretRight class="w-5 h-5" />
                    </a>
                </li>
            {/if}
        </ul>
    </section>

    <section class="w-full text-muted-foreground">
        <div class="uppercase tracking-wider">
            Appearence
        </div>

        <ul class="w-full">
            <li>
                <ToggleDark />
                <FailedPublishesIndicator />
            </li>
            <li>
                <a href="/settings/drafts">
                    <span>
                        <Bell class="w-5 h-5" />
                        Drafts
                    </span>
                    <CaretRight class="w-5 h-5" />
                </a>
            </li>
        </ul>
    </section>

    <ul class="w-full text-muted-foreground">
        <li>
            <a href="/settings/notifications">
                <span>
                    <Bell class="w-5 h-5" />
                    Notifications
                </span>
                <CaretRight class="w-5 h-5" />
            </a>
        </li>

        <li>
            <a href="/settings/network">
                <span>
                    <ShareNetwork class="w-5 h-5" />
                    Network
                </span>
                <CaretRight class="w-5 h-5" />
            </a>
        </li>

        <li>
            <a href="/settings/privacy">
                <span>
                    <Keyhole class="w-5 h-5" />
                    Privacy
                </span>
                <CaretRight class="w-5 h-5" />
            </a>
        </li>

        <li>
            <a href="/settings/services">
                <span>
                    <Package class="w-5 h-5" />
                    Services
                </span>
                <CaretRight class="w-5 h-5" />
            </a>
        </li>

        <div class="divider my-0"></div>

        <li>
            <a href="/settings/developer">
                <span>
                    <Code class="w-5 h-5" />
                    Developer
                </span>
                <CaretRight class="w-5 h-5" />
            </a>
        </li>
    </ul>
{/if}
</div>

<style>
    ul {
        @apply flex flex-col mb-10;
    }

    li a {
        @apply flex flex-row items-center justify-between;
        @apply py-2 text-lg;
    }

    li a:hover {
        @apply text-foreground;
    }

    li a span {
        @apply flex flex-row items-center gap-2;
    }

    li:not(:last-child) {
        @apply border-b border-border;
    }

</style>