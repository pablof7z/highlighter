<script lang="ts">
    import { slide } from "svelte/transition";
    import { newToasterMessage, toasterItems } from "$stores/toaster";
</script>

{#if $toasterItems}
    <div class="toast toast-end">
        {#each $toasterItems as item}
            <div class="alert alert-{item.level}" transition:slide>
                <span>{item.message}</span>
            </div>
        {/each}
    </div>
{/if}
<div class="hidden alert-error alert-info alert-success alert-warn"></div>