<script lang="ts">
	import currentUser from "$stores/currentUser";
import Avatar from '$components/User/Avatar.svelte';
import { ndk } from "$stores/ndk.js";
	import { NDKEvent, NDKKind, NDKUser } from "@nostr-dev-kit/ndk";
	import { ArrowRight } from "phosphor-svelte";
	import Button from "$components/ui/button/button.svelte";

    export let user: NDKUser;
    export let authorUrl: string;

    let memberList: NDKEvent | null | undefined;
    $ndk.fetchEvent(
        { kinds: [NDKKind.GroupMembers], "#d": [user.pubkey] },
    ).then((res) => memberList = res);
</script>

<div class="backstage-box-container {$$props.class??""}">
    <div class="title">
        <span>
            Community Chat
        </span>

        <a href="{authorUrl}/chat" class="text-sm">
            <ArrowRight class="w-5 h-5" />
        </a>
    </div>

    {#if memberList === null}
        <div class="text-foreground text-center">
            No forum activity
        </div>
    {:else if memberList}
        <div class="flex flex-col gap-3 grow overflow-y-auto overflow-x-clip">
            {#each memberList.getMatchingTags("p") as tag}
                <div class="flex flex-row gap-2">
                    <Avatar pubkey={tag[1]} size="small" />
                    <div class="flex flex-col items-start">
                    </div>
                </div>
            {/each}
        </div>
    {/if}

    {#if user.pubkey === $currentUser?.pubkey}
        <Button variant="outline" size="sm" class="w-full">
            Add new members
        </Button>
    {/if}
</div>