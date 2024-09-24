<script lang="ts">
	import RadioButton from "$components/Forms/RadioButton.svelte";
	import Badge from "$components/ui/badge/badge.svelte";
	import { Star } from "phosphor-svelte";
	import { Writable } from "svelte/store";
	import { CreateState } from "./index.js";

    export let state: Writable<CreateState>;
    
    let monetizationType = $state.monetization ?? "v4v";

    $: state.update(s => ({ ...s, monetization: monetizationType }));
</script>

<div class="flex flex-col gap-4 w-full grow">
    <RadioButton color="gold" bind:currentValue={monetizationType} value="v4v" class="h-auto w-full">
        <div class="text-lg">Value-for-value</div>

        <div slot="description" class="text-muted-foreground lg:text-xs text-sm flex flex-col gap-2">
            <p>Provide all your content for free and let your community support you with tips.</p>

            <Badge class="bg-gold text-black w-fit">
                Maximizes distribution
            </Badge>
        </div>
    </RadioButton>

    <RadioButton color="gold" bind:currentValue={monetizationType} value="subscription" class="h-auto w-full">
        <div class="text-lg text-gold flex flex-row items-start gap-1">
            <Star size={24} class="text-gold inline" weight="fill" />
            <span class="">Subscription</span>
        </div>

        <div slot="description" class="text-muted-foreground lg:text-xs text-sm">
            <p>
                Offer exclusive content to your subscribers for a recurring subscription.
            </p>
        </div>
    </RadioButton>
</div>