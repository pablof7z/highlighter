<script lang="ts">
    export let icon: any;
    export let title: string;
    export let comingSoon = false;
    export let href: string | undefined = "#";
</script>

<a {href} class="
    rounded-2xl justify-center items-center inline-flex
    flex-row sm:flex-col
    flex-none
    py-10 sm:px-0 sm:py-6
    gap-4 sm:gap-2
    relative
">
    {#if comingSoon}
        <div class="badge border-none whitespace-nowrap py-4 bg-neutral-900 absolute -top-5">
            <span class="text-neutral-500 text-xs font-semibold px-1 whitespace-nowrap">
                Coming soon
            </span>
        </div>
    {/if}
    <div class="bg w-10 h-10 rounded-lg backdrop-blur-lg justify-center items-center gap-2.5 inline-flex p-2">
        <svelte:component this={icon} class="w-full h-full" weight="fill" />
    </div>
    <div class="text-white text-opacity-70 text-sm font-medium">
        {title}
    </div>
</a>

<style lang="postcss">
    .bg {
        background: radial-gradient(100.21% 187.14% at 0% 0.15%, #BD9488aa 0%, #7092A0aa 100%);
    }

    a {
        @apply bg-white/5 hover:bg-white/10;
        @apply transition-all duration-300;
    }
</style>
