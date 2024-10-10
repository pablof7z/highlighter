<script lang="ts">
	import BlossomUpload from "$components/buttons/BlossomUpload.svelte";
	import { Input } from "$components/ui/input";
	import { NDKUserProfile } from "@nostr-dev-kit/ndk";
	import { Camera, Plus } from "phosphor-svelte";
	import { NavigationOption } from "../../../app";
	import InputArray from "$components/ui/input/InputArray.svelte";
	import { defaultRelays } from "$utils/const";
	import { writable, Writable } from "svelte/store";
	import { CreateState } from ".";
	import UserProfile from "$components/User/UserProfile.svelte";
	import currentUser from "$stores/currentUser";
	import Textarea from "$components/ui/textarea/textarea.svelte";
	import { Button } from "$components/ui/button";

    let userProfile: NDKUserProfile;

    export let state: Writable<CreateState>;

    let showAdvanced = false;

    let name: string;
    let about: string;
    let picture: string;
    let relays = writable<string[]>(defaultRelays);

    $: if (userProfile) {
		const n = userProfile.displayName ?? userProfile.name
		if (n) name ??= `${n}'s Highlighter`
		picture ??= userProfile.image;
		about ??= userProfile.about;
	}

    $: state.update(s => ({ ...s, name, about, picture, relays: $relays }));

    function uploaded(e) {
        picture = e.detail.url;
    }
</script>

<UserProfile bind:userProfile user={$currentUser} />

<div class="flex flex-col gap-6">
    <div class="flex flex-row items-center gap-4">
        <BlossomUpload type="image" on:uploaded={uploaded}>
            <button class="h-16 w-16 relative rounded-full overflow-clip flex flex-row items-center justify-center {picture ? 'bg-transparent' : 'bg-accent/50'}">
                {#if picture}
                    <img src={picture} class="absolute w-full h-full object-cover z-0 opacity-80" />
                {/if}
                <Camera size={32} class="z-10 {picture ? 'opacity-50' : 'opacity-100'}" />
            </button>
        </BlossomUpload>

        <div class="flex flex-col w-full">
            <Input bind:value={name} placeholder="Name" class="text-xl py-6" />
        </div>
    </div>

    <Textarea
        bind:value={about}
        class="
            text-lg border border-border p-4 rounded
        "
        placeholder="Description"
    />

    <p>
        <Button variant="link" size="sm" on:click={() => showAdvanced = !showAdvanced}>
            Advanced
        </Button>
    </p>

    {#if showAdvanced}
        <div class="flex flex-col gap-1">
            <div class="font-bold">Relays</div>
            <div class="text-sm text-muted-foreground">
                Specify NIP-29 relays for your community.
            </div>
            <InputArray bind:values={relays} />
        </div>
    {/if}
</div>