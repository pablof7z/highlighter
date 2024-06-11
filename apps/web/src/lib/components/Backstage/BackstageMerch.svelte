<script lang="ts">
	import { Button } from "$components/ui/button";
	import currentUser from "$stores/currentUser";
	import { NDKUser } from "@nostr-dev-kit/ndk";
	import { ArrowRight } from "phosphor-svelte";

    export let user: NDKUser;
</script>

<div class="backstage-box-container {$$props.class??""}">
    <div class="title">
        <span>
            Merch
        </span>
    </div>

    <div class="text-sm">
        {#if user.pubkey === $currentUser?.pubkey}
            Not enabled in your profile yet.
        {:else}
            No merch yet.
        {/if}
    </div>
</div>