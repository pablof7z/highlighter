<script lang="ts">
	import Avatar from "$components/User/Avatar.svelte";
	import UserProfile from "$components/User/UserProfile.svelte";
	import { nicelyFormattedMilliSatNumber } from "$utils";
	import { NDKZapInvoice } from "@nostr-dev-kit/ndk";
	import { Lightning } from "phosphor-svelte";
	import { SvelteComponent } from "svelte";

    export let zap: NDKZapInvoice;
    export let avatarSize: "tiny" | "small" | "medium" | "large" = "tiny";
    export let comment: "show" | "hover" | "hide" = "hover";
    export let icon: typeof SvelteComponent = Lightning;
    export let iconProps = { weight: 'fill', class: "w-4 h-4 inline text-muted-foreground mr-1" };
</script>

<UserProfile pubkey={zap.zappee} let:userProfile let:fetching let:authorUrl>
    {#key fetching}
        <a href={authorUrl} class="
            relative overflow-hidden text-secondary-foreground
            flex-none
            flex flex-row rounded-full group bg-secondary px-2 py-1 items-center {$$props.class??""}
            transition-all duration-300 w-auto group
        ">
            <span class="font-light mr-3 whitespace-nowrap {$$props.class??""}">
                <svelte:component this={icon} {...iconProps} />
                {nicelyFormattedMilliSatNumber(zap.amount)}
            </span>
            {#key zap.zappee}
                <Avatar pubkey={zap.zappee} {userProfile} {fetching} size={avatarSize} />
                {#if fetching && userProfile}
                    fetching but have user profile!
                {/if}
            {/key}
            {#if zap.comment && comment !== "hide"}
                <span class="
                    transition-all duration-300 whitespace-nowrap line-clamp-1
                    {comment === "hover" ? "max-w-0 group-hover:max-w-[20rem]" : ""}
                ">
                    <div class="pl-3">
                        {zap.comment}
                    </div>
                </span>
            {/if}
        </a>
    {/key}
</UserProfile>