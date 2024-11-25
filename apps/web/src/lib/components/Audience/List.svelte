<script lang="ts">
    import * as Audience from "$components/Audience";
    import CreateTierListModal from "$modals/CreateTierListModal/";
	import { groupsList, tierList } from "$stores/session";
	import RadioButton from "$components/Forms/RadioButton.svelte";
	import { Button } from "$components/ui/button";
	import { openModal } from "$utils/modal";
	import { Writable } from "svelte/store";
    import * as Groups from "$components/Groups";
	import { Globe, Lock } from "lucide-svelte";

    export let state: Writable<Audience.State>;

    let hasTierList: boolean;

    $: hasTierList = $tierList?.items?.length > 0;

    $: if (!["public", "private"].includes($state.scope??"")) $state.scope = "public";

    function createTierModal(e?: Event) {
        e?.preventDefault();
        e?.stopImmediatePropagation();
        openModal(CreateTierListModal, { onSave })
    }

    function onSave() {
        if ($tierList?.items.length > 0) {
            $state.scope = 'private';
        }
    }

    $: if (!hasTierList && $state.scope === 'private') {
        createTierModal();
        $state.scope = 'public';
    }

    $: if ($tierList) {
        console.log('tierlist', $tierList);
    }
</script>

<div class="flex flex-col gap-2">
    <RadioButton bind:currentValue={$state.scope} value="public" color="default">
        <span class:text-muted-foreground={$state.scope !== "public"}>
            Everyone
        </span>
        <span slot="description">
            Anyone can see, share and interact with this content.
        </span>
        <svelte:fragment slot="icon">
            <Globe />
        </svelte:fragment>
    </RadioButton>

    <RadioButton bind:currentValue={$state.scope} value="private" color="default">
        <span class="{!hasTierList ? "text-muted-foreground/50 strikethrough" : ""}">
            Paid subscribers
        </span>
        <span slot="description">
            Only paid subscribers will be able to see this content.
        </span>
        <svelte:fragment slot="icon">
            <Lock />
        </svelte:fragment>

        {#if !hasTierList}
            <Button variant="link" size="xs" class="text-gold" on:click={createTierModal}>
                Turn on paid subscriptions
            </Button>
        {/if}
    </RadioButton>

    tier list: {$tierList?.items?.length}
    groups list:    {$groupsList?.items?.length}

    {#if $tierList && $tierList.items.length > 0 && $groupsList && $groupsList.items.length > 0}
        <div class="flex flex-col border bg-secondary/30 rounded p-2 px-4 w-full text-sm mt-4">
            <Groups.RootList tags={$groupsList.items} let:group>
                <Audience.GroupTiers {group} {state} />
            </Groups.RootList>
        </div>
    {/if}
    
</div>
