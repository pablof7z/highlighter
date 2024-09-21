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

    export let buttonLabel: string;
    export let title: string;
    export let nextStep: string;
    export let communityType: string;
    export let userProfile: NDKUserProfile;
    export let extraButtons: NavigationOption[];

    export let state: Writable<CreateState>;

    let showAdvanced = false;
    const toggleAdvanced = () => showAdvanced = !showAdvanced;

    extraButtons = [
        { name: "Advanced", buttonProps: { variant: 'outline', size: 'xs' }, fn: toggleAdvanced }
    ];

    buttonLabel = "Create";
    title = "Profile";
    nextStep = "monetization";

    let name: string = $state.name ?? userProfile?.name ? `${userProfile?.name}'s Publication` ?? "" : "";
    let about: string = $state.about ?? userProfile?.about ?? "";
    let picture: string = $state.picture ?? userProfile?.picture ?? "";
    let relays = writable<string[]>(defaultRelays);

    $: state.update(s => ({ ...s, name, about, picture, relays: $relays }));

    function uploaded(e) {
        picture = e.detail.url;
    }
</script>

<div class="flex flex-col gap-6">
    <div class="flex flex-row items-center gap-4">
        <BlossomUpload type="image" on:uploaded={uploaded}>
            <button class="h-16 w-16 relative rounded-full overflow-clip flex flex-row items-center justify-center bg-accent/50">
                {#if picture}
                    <img src={picture} class="absolute w-full h-full object-cover z-0 opacity-50" />
                {/if}
                <Camera size={32} class="z-10" />
            </button>
        </BlossomUpload>

        <div class="flex flex-col w-full">
            <Input bind:value={name} placeholder="Name" class="text-xl py-6" />
        </div>
    </div>

    <!-- <ContentEditor
        bind:content={about}
        allowMarkdown={false}
        toolbar={false}
        class="
            text-lg border border-border p-4 rounded
        "
        placeholder="Description"
    /> -->

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