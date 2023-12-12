<script lang="ts">
    import Input from "$components/Forms/Input.svelte";

    export let value: string = "";
    export let editing = false;
</script>

{#if editing}
    <Input bind:value={value} class={$$props.class??""} />
{:else}
    <span class="{$$props.class??""}">{value}</span>
{/if}

