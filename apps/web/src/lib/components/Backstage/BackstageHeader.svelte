<script lang="ts">
	import { NDKUser } from "@nostr-dev-kit/ndk";
	import { UserProfileType } from "../../../app";
	import BackstageHeaderTopBackers from "./BackstageHeaderTopBackers.svelte";
	import Avatar from '$components/User/Avatar.svelte';
import Name from '$components/User/Name.svelte';
	import BackstageHeaderTopZappedBy from "./BackstageHeaderTopZappedBy.svelte";
	import StylishContainer from "$components/PageElements/StylishContainer.svelte";

    export let user: NDKUser;
    export let userProfile: UserProfileType;
</script>

<StylishContainer class="flex flex-col-reverse lg:flex-row gap-4 items-stretch justify-between p-4">
    <div class="lg:w-3/12 backstage-box-container !p-2">
        <BackstageHeaderTopBackers {user} />
    </div>

    <div class="lg:w-5/12 flex flex-col gap-2 items-center justify-center">
        <Avatar {user} {userProfile} size="large" />
        <span class="text-foreground font-medium text-lg">
            <Name {userProfile} class="inline" />'s
        </span>

        Backstage Community
    </div>

    <div class="lg:w-3/12 backstage-box-container !p-2 max-lg:hidden">
        <BackstageHeaderTopZappedBy {user} />
    </div>
</StylishContainer>