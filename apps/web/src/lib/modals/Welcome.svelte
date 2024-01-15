<script lang="ts">
	import { ArrowRight, MagicWand, UserSwitch, UsersThree } from 'phosphor-svelte';
	import { Name, user } from '@kind0/ui-common';
	import UserProfile from '$components/User/UserProfile.svelte';
</script>

<div class="mt-5">
    <div class="prose text-neutral-500 my-3">
        {#if $user}
            <UserProfile user={$user} let:userProfile let:fetching>
                <h1 class="!text-black text-xl font-semibold leading-normal mb-0">
                    Welcome, <Name {userProfile} {fetching} />!
                </h1>
            </UserProfile>
        {/if}

        <p class="mt-2">
            Highlighter is a gateway into the Nostr ecosystem, a network that allows
            for direct communication between users.
        </p>

        <p>
            When you publish in Nostr,
            <b>you don't restrict yourself to a single platform,
            no longer posting on Medium, Twitter and Reddit.</b>
        </p>

        <div class="w-full flex flex-col gap-2">
            <div class="flex flex-row items-start w-full">
                <MagicWand class="w-6 h-6 mr-2 text-accent flex-none" />
                <div class="flex flex-col">
                    Start publishing and earning from your content
                    immediately.
                </div>
            </div>

            <div class="flex flex-row items-start w-full">
                <UserSwitch class="w-6 h-6 mr-2 text-accent flex-none" />
                <div class="flex flex-col">
                    Allow your audience to disseminate your content, allowing you to reach new people organically
                    and without ads.
                </div>
            </div>
        </div>
    </div>

    <a href="/welcome/creators" class="button button-primary w-full">
        Continue
    </a>
</div>