<script lang="ts">
	import MobileHeader from "$components/Page/MobileHeader.svelte";


</script>

<MobileHeader backButton={"/welcome"} title="Referrals">
</MobileHeader>

<div class="flex flex-col p-6">
    <div class="flex flex-col max-w-prose w-full">
        <h1 class="text-[80px] font-semibold ">
            Rerrals.
        </h1>
        <h2 class="text-3xl">
            Like never before
        </h2>

        <div class="prose text-xl mt-4 opacity-60 font-light">
            Highlighter, built on Nostr, allows for direct monetization of your content in hundreds
            of different platform. Your content can be displayed in premium spots. In this area
            you will be able to configure a voluntary referral program to encourage clients and readers
            to highlight your content.
        </div>

        <div class="text-xl py-6">
            Coming soon
        </div>
    </div>
</div>

<style>
    h1 {
        @apply text-white leading-tight text-[80px];
    }

    h2 {
        @apply text-neutral-500 leading-tight;
    }
</style>