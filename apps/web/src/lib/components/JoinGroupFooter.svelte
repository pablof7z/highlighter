<script lang="ts">
	import { NDKSimpleGroup } from "@nostr-dev-kit/ndk";
	import { Button } from "./ui/button";
	import currentUser from "$stores/currentUser";

    export let group: NDKSimpleGroup;

    async function join() {
        group.requestToJoin($currentUser.pubkey, "please, I want to learn about horses!")
    }
</script>

<div class="p-2">
    <Button variant="accent" class="w-full" on:click={join}>
        View Info & Join
    </Button>
</div>