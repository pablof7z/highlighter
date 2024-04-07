<script lang="ts">
	import UserProfile from "$components/User/UserProfile.svelte";
	import ButtonWithExtraText from "$components/buttons/ButtonWithExtraText.svelte";
	import { Avatar, nicelyFormattedMilliSatNumber } from "@kind0/ui-common";
	import { NDKZapInvoice } from "@nostr-dev-kit/ndk";
	import { Lightning } from "phosphor-svelte";
	import { slide } from "svelte/transition";

    export let zap: NDKZapInvoice;
    export let avatarSize: "tiny" | "small" | "medium" | "large" = "tiny";
    export let comment: "show" | "hover" | "hide" = "hover";
</script>

<UserProfile pubkey={zap.zappee} let:userProfile let:fetching let:authorUrl>
    {#if userProfile}
        <a href={authorUrl} class="
            relative overflow-hidden
            flex flex-row rounded-full group bg-base-300 px-2 py-1 items-center {$$props.class??""}
            transition-all duration-300 w-auto group
        " transition:slide={{ axis: 'x'}}>
            <span class="text-white font-light mr-3">
                <Lightning class="w-4 h-4 inline" weight="fill" />
                {nicelyFormattedMilliSatNumber(zap.amount)}
            </span>
            <Avatar pubkey={zap.zappee} {userProfile} size={avatarSize} />
            {#if zap.comment && comment !== "hide"}
                <span class="
                    text-white/70 transition-all duration-300 text-white whitespace-nowrap line-clamp-1
                    {comment === "hover" ? "max-w-0 group-hover:max-w-[20rem]" : ""}
                ">
                    <div class="pl-3">
                        {zap.comment}
                    </div>
                </span>
            {/if}
        </a>
    {/if}
</UserProfile>