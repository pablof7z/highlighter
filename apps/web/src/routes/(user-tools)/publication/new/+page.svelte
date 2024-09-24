<script lang="ts">
	import { ArrowRight } from 'phosphor-svelte';
	import { presets } from "$components/Publication/Pricing";
	import Option from "$components/Publication/Pricing/Option.svelte";
	import AvatarSelection from "$components/Signup/AvatarSelection.svelte";
	import { Input } from "$components/ui/input";
	import UserProfile from "$components/User/UserProfile.svelte";
	import currentUser from "$stores/currentUser";
	import { setLayout } from "$stores/layout";
	import { userProfile } from "$stores/session";
	import { openModal } from "$utils/modal";
	import { NDKUserProfile } from "@nostr-dev-kit/ndk";
	import { writable } from 'svelte/store';
	import type { CreateState } from "$components/Publication";
    import * as Publication from "$components/Publication";
	import { Button } from "$components/ui/button";
	import { slide } from "svelte/transition";

	setLayout({
		title: 'New Publication',
		fullWidth: false,
		back: { url: '/' }
	})

	
	let state = writable<CreateState>({
		monetization: 'v4v',
		name: undefined,
		about: undefined,
		picture: undefined
	});

    let create: (state: CreateState) => Promise<void>;

    let status: 'initial' | 'creating' | 'created' = 'initial'

    async function next() {
        status = 'creating';
        try {
            await create($state);
            status = 'created';
        } catch (e) {
            status = 'initial';
        }
    }
</script>

<div class="flex flex-col gap-6">
	<div class="flex flex-row items-start justify-between my-10">
		<div class="flex flex-col items-start">
			<h1 class="text-5xl font-bold mb-2">
				Publication
			</h1>
			<h3 class="font-light text-muted-foreground text-lg bg-secondary rounded-lg p-4 w-full">
				<p>A place to share your work with your audience.</p>

				<p>Publish articles, stories, videos or any type of content, and your audience can subscribe to your publication to receive updates.</p>
			</h3>
		</div>
	</div>
</div>

<Publication.Root bind:state bind:create>
    <div class="flex flex-col divide-y wrapper">
        <div class="flex flex-row gap-10">
            <div class="sticky top-0 w-1/4">
                <div class="font-bold text-lg">
                    Publication Details
                </div>

                <div class="text-muted-foreground text-sm flex flex-col gap-2">
                    <p>Describe your publication.</p>

                    <p>You can change these settings later.</p>
                </div>
            </div>
            <div class="flex flex-col gap-10 grow">
                <Publication.Profile {state} />
            </div>
        </div>
        
        <div class="flex flex-row gap-10">
            <div class="sticky top-0 w-1/4">
                <div class="font-bold text-lg">
                    Monetization
                </div>
                <div class="text-muted-foreground text-sm">
                    How would you like to monetize your work?
                </div>
            </div>
            <div class="flex flex-col gap-10 grow">
                <Publication.Monetization {state} />
            </div>
        </div>
    
        {#if $state.monetization !== 'v4v'}
            <div class="flex flex-col gap-6" transition:slide>
                <div class="flex flex-row gap-10">
                    <div class="sticky top-0 w-1/4">
                        <div class="font-bold text-lg">
                            Pricing
                        </div>
                        <div class="text-muted-foreground text-sm">
                            Set the price for your publication.
                        </div>
                    </div>
                    <div class="flex flex-col gap-4 grow">
                        <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                            <Publication.Pricing {state} />
                        </div>
                    </div>
                </div>
            </div>
        
            
        {/if}

    </div>
    <div class="flex justify-center w-full">
        <Button size="lg" variant="accent" class="px-10" on:click={next} disabled={status !== 'initial'}>
            Create
            {$state.name}
            <ArrowRight size={32} class="inline ml-2" />
        </Button>
    </div>
</Publication.Root>

<style lang="postcss">
    .wrapper > div {
        @apply py-10;
    }
</style>