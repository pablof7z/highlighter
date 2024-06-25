<script lang="ts">
    import AvatarWithName from "$components/User/AvatarWithName.svelte";
	import { Bell, CaretRight, Code, Key, Keyhole, Lightning, Package, ShareNetwork, Wallet } from "phosphor-svelte";
	import { logout } from "$utils/login";
	import currentUser from "$stores/currentUser";
	import { Block } from "konsta/svelte";
	import { Button } from "$components/ui/button";
	import { NDKPrivateKeySigner } from "@nostr-dev-kit/ndk";
	import { ndk } from "$stores/ndk";
	import ToggleDark from "$components/buttons/ToggleDark.svelte";

    let authorUrl: string;
</script>

<Block>
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
            
            <li>
                <a href="/settings/tiers">
                    <span>
                        <ShareNetwork class="w-5 h-5" />
                        Tiers
                    </span>
                    <CaretRight class="w-5 h-5" />
                </a>
            </li>

            <li>
                <a href="/settings/subscriptions">
                    <span>
                        <ShareNetwork class="w-5 h-5" />
                        Subscriptions
                    </span>
                    <CaretRight class="w-5 h-5" />
                </a>
            </li>

            <li>
                <a href="/settings/wallet">
                    <span>
                        <Lightning class="w-5 h-5" />
                        Wallet
                    </span>
                    <CaretRight class="w-5 h-5" />
                </a>
            </li>
        </ul>
    </section>

    <section class="w-full text-muted-foreground">
        <div class="uppercase tracking-wider">
            Appearence
        </div>

        <ul class="w-full">
            <li>
                <ToggleDark />
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
</Block>

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