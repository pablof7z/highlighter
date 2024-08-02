<script lang="ts">
	import RadioButton from "$components/Forms/RadioButton.svelte";
	import { Writable } from "svelte/store";
	import { CreateState } from ".";
	import Name from "$components/User/Name.svelte";
	import currentUser from "$stores/currentUser";

    export let state: Writable<CreateState>;
    export let communityType: string = $state.type ?? "personal";
    export let nextStep: string;

    $: state.update(s => ({ ...s, type: communityType }));
    
    nextStep = "monetization";
    
    export let title: string;
    title = "Setup your creator profile";

    export let buttonLabel: string;
    buttonLabel = "Next: Monetization";
</script>

<div class="flex flex-col gap-4 w-full grow">
    <p>
        Choose what type of community best represents the type of content you create.
    </p>

    <RadioButton bind:currentValue={communityType} value="personal" class="h-auto w-full">
        <b class="text-lg">Personal Community</b>

        <div slot="description" class="text-muted-foreground lg:text-xs text-sm flex flex-col gap-2">
            <p>Create a community centered around your personal brand.</p>

            <div class="text-xs">
                E.g. <Name user={$currentUser} />'s Fans
            </div>
        </div>
    </RadioButton>

    <RadioButton bind:currentValue={communityType} value="theme" class="h-auto w-full">
        <b class="text-lg">Topic-based Community</b>

        <div slot="description" class="text-muted-foreground lg:text-xs text-sm flex flex-col gap-2">
            <p>Community centered around a specific topic or theme.</p>

            <div class="text-xs">
                E.g. Journaling Afficionados
            </div>
        </div>
    </RadioButton>

    <p class="text-muted-foreground text-sm">
        You can always change this later.
    </p>
</div>