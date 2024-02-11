<script lang="ts">
    export let title: string | undefined = undefined;
</script>

<!-- <div class="border-b border-base-300 flex flex-row items-center justify-between gap-8 p-6 relative">
    <h1 class="2xl:absolute">
        Discover
    </h1> -->

<div class="
    w-full
    max-lg:!hidden
    max-lg:top-0 max-lg:left-0 max-lg:h-screen

    lg:flex-none
    h-full
    bg-base-100 max-lg:mobile-nav
    lg:rounded-3xl
    flex-col justify-start items-start gap-6 inline-flex shrink-0 {$$props.class??""}
">
    {#if title}
        <div class="
            self-stretch justify-between items-center gap-6 inline-flex
            py-4 w-full px-4
            overflow-clip truncate
        ">
            <h1 class="
                grow shrink basis-0 text-white font-semibold
                flex flex-row items-center gap-2
                text-left
                max-lg:text-lg
                lg:text-2xl
                whitespace-nowrap
            ">
                {title}
            </h1>

            {#if $$slots.headerRight}
                <slot name="headerRight" />
            {/if}
        </div>
    {/if}

    <div
        class="
        max-lg:max-h-[50dvh]
        h-full
        overflow-y-auto
        flex-col justify-start items-start gap-3 flex w-full
        px-4
        {$$props.innerClass??""}
    ">
        <slot />
    </div>
</div>