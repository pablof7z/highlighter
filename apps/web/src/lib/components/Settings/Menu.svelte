<script lang="ts">
	import { user } from "@kind0/ui-common";
    import AvatarWithName from "$components/User/AvatarWithName.svelte";
	import { CaretRight, Code, Keyhole, Package, ShareNetwork } from "phosphor-svelte";
	import { logout } from "$utils/login";

    let authorUrl: string;


</script>

{#if $user}
    <AvatarWithName user={$user} bind:authorUrl nameClass="text-xl text-white font-semibold"
        spacing="gap-4"
        avatarSize="large" avatarClass="w-16 h-16"
    />

    <div class="flex flex-col sm:flex-row gap-4 items-stretch justify-evenly w-full">
        <a href={authorUrl} class="btn btn-neutral sm:w-1/3">
            View Profile
        </a>
        <a href="/settings/profile" class="btn btn-neutral sm:w-1/3">
            Edit Profile
        </a>
        <button class="btn btn-neutral sm:w-1/3" on:click={logout}>
            Log out
        </button>
    </div>

    <section class="w-full">
        <div class="text-neutral-400 uppercase tracking-wider">
            Account
        </div>

        <ul class="w-full">
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
        </ul>
    </section>

    <div class="divider my-0"></div>

    <ul class="w-full">
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

<style>
    ul {
        @apply flex flex-col;
    }

    li a {
        @apply flex flex-row items-center justify-between;
        @apply py-2 text-lg;
    }

    li a:hover {
        @apply text-white;
    }

    li a span {
        @apply flex flex-row items-center gap-2;
    }

    li:not(:last-child) {
        @apply border-b-2 border-base-200;
    }

</style>