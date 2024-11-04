<script lang="ts">
    import * as Audience from "$components/Audience";
    import CreateTierListModal from "$modals/CreateTierListModal/";
	import { groupsList, tierList } from "$stores/session";
	import RadioButton from "$components/Forms/RadioButton.svelte";
	import { Button } from "$components/ui/button";
	import { openModal } from "$utils/modal";
	import { Writable } from "svelte/store";
    import * as Groups from "$components/Groups";

    export let state: Writable<Audience.State>;

    let hasTierList: boolean;

    $: hasTierList = $tierList?.items?.length > 0;

    $: if (!["public", "private"].includes($state.scope??"")) $state.scope = "public";

    function createTierModal(e: Event) {
        e.preventDefault();
        e.stopImmediatePropagation();
        openModal(CreateTierListModal, { onSave })
    }

    function onSave() {
        if ($tierList?.items.length > 0) {
            $state.scope = 'private';
        }
    }

    $: console.log('groups', $state.groups);
</script>

<div class="flex flex-col border rounded-lg">
    <RadioButton bind:currentValue={$state.scope} value="public" color="default" class="!border-none">
        <span class:text-muted-foreground={$state.scope !== "public"}>
            Everyone
        </span>
    </RadioButton>

    <RadioButton bind:currentValue={$state.scope} value="private" color="default" class='!border-none'>
        <span class:opacity-30={!hasTierList}>
            Paid subscribers
        </span>

        {#if !hasTierList}
            <Button variant="link" size="xs" class="text-gold" on:click={createTierModal}>
                Turn on paid subscriptions
            </Button>
        {/if}
    </RadioButton>

    {#if $state.scope === 'private' && $tierList && $tierList.items.length > 0}
        <div class="flex flex-col border bg-secondary/30 rounded p-2 px-4 w-full text-sm mt-4">
            <Groups.RootList tags={$groupsList.items} let:group>
                <Audience.GroupTiers {group} {state} />
            </Groups.RootList>
        </div>
    {/if}
    
</div>
