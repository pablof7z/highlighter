<script lang="ts">
	import { Readable } from "svelte/store";
    import * as Groups from '$components/Groups'
	import RadioButton from "$components/Forms/RadioButton.svelte";
	import Name from "$components/User/Name.svelte";
	import { tierAmountToString } from "$lib/events/tiers";
	import AvatarsPill from "$components/Avatars/AvatarsPill.svelte";

    export let group: Readable<Groups.GroupData>;
    export let currentValue: string
</script>

<div class="flex flex-row items-start gap-4 items-stretch">
    <img src={$group.picture} class="w-24 h-24 object-cover rounded-lg" />

    <div class="flex flex-col items-start">
        <div class="text-lg font-semibold">{$group.name}</div>

        <div class="text-sm text-muted-foreground">
            {$group.about}
        </div>

        <div class="grow"></div>

        {#if $group.members}
            <AvatarsPill pubkeys={$group.members?.members} size="small" />
        {/if}
    </div>
</div>

<div class="flex flex-col gap-2 mt-4">
{#each $group.tiers??[] as tier}
    {#if $group.tiers.length > 1}
        <h2>{tier.title}</h2>
        <p class="text-sm text-muted-foreground">{tier.content}</p>
    {/if}
    <div class="flex flex-row gap-2">
        {#each tier.amounts as amount, index}
            <RadioButton
                bind:currentValue
                value={tier.id + "-" + index}
                class="min-h-16"
            >
                <span class="text-xl">
                    {tierAmountToString(amount)}
                </span>
            </RadioButton>
        {/each}

    </div>
{/each}
<RadioButton bind:currentValue value={"free"}>
    Basic follow for free
</RadioButton>
</div>