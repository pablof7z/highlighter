<script lang="ts">
    import { Option } from "$components/option";
	import User from "$components/PageSidebar/OnboardingCheckingIcons/User.svelte";
	import { Globe, GlobeSimple, UsersThree } from "phosphor-svelte";
	import OptionsList from "$components/OptionsList.svelte";
	import BookmarkFeed from "./BookmarkFeed.svelte";

    const options: Option[] = [];
    let value = "You";

    options.push({ name: "You", value: 'You', icon: User})
    options.push({ name: "Follows", value: 'Follows', icon: UsersThree})
    options.push({ name: "Recent", value: 'Recent', icon: GlobeSimple})
</script>

<OptionsList {options} bind:value class="mt-4 flex flex-row w-full max-sm:gap-0 gap-2 sm:px-4 sm:pb-2 sm:border-b border-base-300" />

{#key value}
    <BookmarkFeed type={value} />
{/key}