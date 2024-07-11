<script lang="ts">
	import JoinGroupFooter from './JoinGroupFooter.svelte';
    import { NDKSimpleGroup, NDKSimpleGroupMemberList, NDKSimpleGroupMetadata } from "@nostr-dev-kit/ndk";
	import { Button } from "./ui/button";
	import currentUser from "$stores/currentUser";
	import { openModal } from "$utils/modal";
    import * as Footer from "$components/Footer";

    export let group: NDKSimpleGroup;
    export let metadata: NDKSimpleGroupMetadata;
    export let members: NDKSimpleGroupMemberList;
    export let admins: NDKSimpleGroupMemberList;

    // async function join() {
    //     group.requestToJoin($currentUser.pubkey, "please, I want to learn about horses!")
    // }
</script>

<Footer.Shell let:open>
    <Button variant="accent" class="w-full" on:click={open}>
        View Info & Join
    </Button>

</Footer.Shell>
