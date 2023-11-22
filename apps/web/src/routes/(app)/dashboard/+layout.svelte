<script lang="ts">
	import { user } from "@kind0/ui-common";


</script>

{#if !$user}
    Must be logged in
{:else}
    <slot />
{/if}