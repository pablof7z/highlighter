<script lang="ts">
    import { loadedEvent } from "$stores/item-view";
    import * as Content from "$components/Content";
</script>

{#if $loadedEvent}
    <Content.Shell
        event={$loadedEvent}
    >
        <slot />
    </Content.Shell>
{/if}