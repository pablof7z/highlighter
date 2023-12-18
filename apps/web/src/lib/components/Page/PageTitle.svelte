<script lang="ts">
    export let title: string;
</script>

<div class="flex flex-row justify-between items-center {$$props.class??""}">
    <h1>
        {title}
    </h1>

    {#if $$slots.default}
        <div>
            <slot />
        </div>
    {/if}
</div>

<style lang="postcss">
    h1 {
        @apply text-white text-2xl font-semibold;
    }
</style>