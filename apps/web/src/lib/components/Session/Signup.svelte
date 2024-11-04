<script lang="ts">
    import { NDKPrivateKeySigner, NDKUser, NDKNip46Signer, NDKEvent } from "@nostr-dev-kit/ndk";
	import type { NDKEventStore } from '@nostr-dev-kit/ndk-svelte';
    import { createEventDispatcher, onMount } from 'svelte';
	import currentUser, { loginMethod, nip46LocalKey, userPubkey } from "$stores/currentUser";
	import { bunkerNDK, ndk } from '$stores/ndk.js';
	import { createGuestAccount } from "$utils/user/guest";
	import Input from "$components/ui/input/input.svelte";
	import Button from "$components/ui/button/button.svelte";
	import { ArrowRight, Play } from "phosphor-svelte";
	import { fillInSkeletonProfile, pkSignup } from "$utils/login";
	import AvatarSelection from "$components/Signup/AvatarSelection.svelte";
    import { createNewWallet } from "$lib/actions/wallet/new.js";
	import { closeModal } from "$utils/modal";
    import * as Card from "$components/ui/card";

    export let mode: string;
    export let title: string;

    title = 'Welcome!'

    let avatar: string;

    let name: string;

    async function startSignup() {
        await pkSignup();

        await fillInSkeletonProfile({
            name,
            picture: avatar,
        })

        closeModal();

        // create wallet
        setTimeout(() => {
            createNewWallet()
        }, 5000);

    }
</script>

<Card.Root>
    <Card.Content class="flex flex-col gap-6">
        <h1 class="pt-3 text-center">Sign Up</h1>

        <p class="text-muted-foreground grow">
            Highlighter is a
            calm place for
            <span class="text-foreground">content creators</span>
            to build long-lasting relationships with their audience.
        </p>

        <div
        class="flex flex-col gap-4 transition-opacity duration-0"
    >
        <div class="flex flex-col items-center gap-2 w-full">
            <AvatarSelection bind:avatar />
        </div>

        <div class="field mx-2">
            <label for="">What should we call you?</label>

            <Input
                bind:value={name}
                class="text-lg p-6"
                placeholder="Johnnie Appleseed"
            />
        </div>

        <Button
            on:click={startSignup}
        >
            Start
            <ArrowRight size={22} class="ml-2" />
        </Button>

        <Button
            variant="outline"
            on:click={() => mode = 'login'}
        >
            Already on Nostr?
        </Button>
    </div>
        
    </Card.Content>
</Card.Root>
