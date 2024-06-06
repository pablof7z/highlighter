<script>

	import Button from "$components/ui/button/button.svelte";

</script>
<div class="max-w-xl mx-auto flex flex-col items-center gap-4  rounded p-4 lg:p-10 {$$props.class??""}">
    <slot name="illustration" />
    <!-- <img src="/images/drafts.png" /> -->

    <p class="text-center text-foreground text-lg">
        <slot />
    </p>

    <Button forceNonMobile size="lg" variant="default" on:click>
        {$$props.cta}
    </Button>

    {#if $$slots.afterCta}
        <slot name="afterCta" />
    {/if}
</div>
