<script lang="ts">
	import currentUser from "$stores/currentUser";
	import { NDKUser } from "@nostr-dev-kit/ndk";
	import { ArrowRight } from "phosphor-svelte";

    export let user: NDKUser;
    export let authorUrl: string;
</script>

<div class="backstage-box-container {$$props.class??""}">
    <div class="title">
        Zap Goals
    </div>

    <div class="text-sm">
        {#if user.pubkey === $currentUser?.pubkey}
            Not enabled in your profile yet.
        {:else}
            No zap goals yet.
        {/if}
    </div>
</div>