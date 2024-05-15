<script lang="ts">
	import currentUser from "$stores/currentUser";
	import { NDKUser } from "@nostr-dev-kit/ndk";
	import { ArrowRight } from "phosphor-svelte";

    export let user: NDKUser;
</script>

<div class="backstage-box-container {$$props.class??""}">
    <div class="flex flex-row justify-between items-center">
        <span class="text-sm">
            Merch
        </span>

        <a href="#" class="text-sm">
            More
            <ArrowRight class="w-5 h-5 inline" />
        </a>
    </div>

    <div class="text-sm backstage-box-container !p-4">
        {#if user.pubkey === $currentUser?.pubkey}
            Not enabled in your profile yet.
        {:else}
            No zap goals yet.
        {/if}
    </div>
</div>