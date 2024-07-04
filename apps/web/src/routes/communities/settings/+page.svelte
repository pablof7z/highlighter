<script lang="ts">
	import { Button } from "$components/ui/button";
	import { loadedGroup } from "$stores/item-view";
	import { ndk } from "$stores/ndk";
	import { Block } from "konsta/svelte";

    function addMember() {
        const pubkey = prompt("Enter the pubkey of the member you want to add");
        if (pubkey) {
            const user = $ndk.getUser({pubkey})
            $loadedGroup.addUser(user);
        }
    }
</script>

<Block>
    
    <h1>Members</h1>
    
    {#if $loadedGroup?.memberList}
        {#each $loadedGroup.memberList.members as member}
            <div>{member}</div>
        {/each}
    {/if}

    <Button on:click={addMember}>
        Add Member
    </Button>

</Block>