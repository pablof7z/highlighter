<div class="max-w-xl mx-auto flex flex-col items-center gap-4  rounded-box p-4 lg:p-10 {$$props.class??""}">
    <slot name="illustration" />
    <!-- <img src="/images/drafts.png" /> -->

    <p class="text-center text-white text-lg">
        <slot />
    </p>

    <button class="button w-fit text-lg px-6" on:click>
        {$$props.cta}
    </button>

    {#if $$slots.afterCta}
        <slot name="afterCta" />
    {/if}
</div>
