<script lang="ts">
    export let title: string;
    export let value: string;
    export let href: string | undefined = undefined;

    let isActive: boolean = false;

    $: isActive = value === title;

    function onClick() {
        value = title;
    }

</script>

{#if !href}
    <button
        role="tab"
        class="tab {$$props.class??""}"
        class:tab-active={isActive}
        on:click={onClick}
    >{title}</button>
{:else}
    <a
        role="tab"
        class="tab {$$props.class??""}"
        class:tab-active={isActive}
        {href}
        on:click={onClick}
    >{title}</a>
{/if}

<style lang="postcss">
    .pill.tab-active {
        @apply !bg-white !text-black;
    }
</style>