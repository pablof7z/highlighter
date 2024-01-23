<script lang="ts">
	import LoadingScreen from "$components/LoadingScreen.svelte";
	import WithItem from "./WithItem.svelte";
    import { MagnifyingGlass } from "phosphor-svelte";
    import Input from "$components/Forms/Input.svelte";
	import AvatarWithName from "$components/User/AvatarWithName.svelte";
</script>

<WithItem let:event let:urlPrefix let:eventType let:isFullVersion>
    {#if event}
        <div class="flex flex-col w-full">
            <div class="border-b border-base-300 flex flex-row items-center justify-between gap-8 py-6 fixed w-full border mobile-nav !bg-base-100">
                <div class="flex-col justify-start items-start gap-8 flex mx-auto max-w-3xl w-full border">
                    <AvatarWithName user={event.author} />
                </div>
            </div>

            <slot />
        </div>
    {/if}
</WithItem>

<style lang="postcss">
    h1 {
        @apply text-white font-semibold text-2xl;
    }
</style>