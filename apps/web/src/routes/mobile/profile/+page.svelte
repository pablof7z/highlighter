<script lang="ts">
	import { page } from "$app/stores";
	import { ndk } from "$stores/ndk.js";
	import { NDKUser } from "@nostr-dev-kit/ndk";
    import * as User from "$components/User";

    let userId: string | null;
    let view: string;

    let user: NDKUser;

    $: {
        userId = $page.url.searchParams.get('userId');
        view = $page.url.searchParams.get('view') ?? "profile";
        if (userId) user = $ndk.getUser({npub: userId});
    }
</script>

{#if user}
    {#key userId}
        <User.Root {user} let:user let:notes let:highlights let:articles let:videos let:groupsList let:curations let:cashuMintList let:pinList let:tierList let:tiers let:groups let:groupsMetadata let:eosed let:userProfile let:fetching let:authorUrl>
            <User.Shell {user} {notes} {highlights} {articles} {videos} {groupsList} {curations} {cashuMintList} {pinList} {tierList} {tiers} {groups} {groupsMetadata} {eosed} {userProfile} {fetching} {authorUrl}>
                {#if view === "profile"}
                    <User.Views.Home {user} {userProfile} {authorUrl} {groupsList} />
                {:else if view === 'notes'}
                    <User.Views.Notes {user} {userProfile} {authorUrl} />
                {:else if view === 'articles'}
                    <User.Views.Articles {user} />
                {:else if view === 'videos'}
                    <User.Views.Videos {user} />
                {/if}
            </User.Shell>
        </User.Root>
    {/key}
{/if}