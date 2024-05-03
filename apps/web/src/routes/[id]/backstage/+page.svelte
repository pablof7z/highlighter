<script lang="ts">
	import { page } from "$app/stores";
	import BackstageContentArea from "$components/Backstage/BackstageContentArea.svelte";
    import UserProfile from "$components/User/UserProfile.svelte";
	import { layoutMode, layoutNavState, pageNavigationOptions } from "$stores/layout";
	import { UserProfileType } from "../../../app";
    import BackstageForumNotes from "$components/Backstage/BackstageForumNotes.svelte";
	import BackstageZapRaisers from "$components/Backstage/BackstageZapRaisers.svelte";
    import BackstageChat from "$components/Backstage/BackstageChat.svelte";
	import BackstageMerch from "$components/Backstage/BackstageMerch.svelte";

    let { user } = $page.data;

    $layoutMode = "full-width";
    $layoutNavState = "collapsed";

    let userProfile: UserProfileType;
    let authorUrl: string;
</script>

<UserProfile {user} bind:userProfile bind:authorUrl />

<div class="flex flex-col lg:flex-row gap-6">
    <div class="lg:w-[300px] sticky top-0">
        <div class="
            flex flex-col md:flex-row lg:flex-col gap-6 items-stretch md:justify-stretch max-md:h-full
            sticky top-[var(--layout-header-height)]
        ">
            <BackstageForumNotes {user} {authorUrl} class="w-full md:w-1/3 lg:w-full max-md:grow" />
            <BackstageChat {user} {authorUrl} class="w-full md:w-1/3 lg:w-full max-md:grow" />
            <BackstageZapRaisers {user} {authorUrl} class="w-full md:w-1/3 lg:w-full max-md:grow" />
            <BackstageMerch {user} {authorUrl} class="w-full md:w-1/3 lg:w-full max-md:grow" />
        </div>
    </div>
    <div class="grow">
        <BackstageContentArea {user} />
    </div>
</div>

