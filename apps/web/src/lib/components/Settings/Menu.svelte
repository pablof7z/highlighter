<script lang="ts">
	import { user } from "@kind0/ui-common";
    import AvatarWithName from "$components/User/AvatarWithName.svelte";
	import { CaretRight, Keyhole, Package, ShareNetwork } from "phosphor-svelte";
</script>

{#if $user}
    <AvatarWithName user={$user} nameClass="text-xl text-white font-semibold"
        spacing="gap-4"
        avatarSize="large"
    />

    <div class="flex flex-row gap-4 items-stretch justify-evenly w-full">
        <button class="btn btn-neutral w-1/2">
            Switch account
        </button>
        <button class="btn btn-neutral w-1/2">
            Log out
        </button>
    </div>

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