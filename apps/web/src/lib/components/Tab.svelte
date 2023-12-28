<script lang="ts">
    export let title: string;
    export let value: string;

    let isActive: boolean = false;

    $: isActive = value === title;

    function onClick() {
        value = title;
    }

</script>

<button
    role="tab"
    class="tab {$$props.class??""}"
    class:tab-active={isActive}
    on:click={onClick}
>{title}</button>