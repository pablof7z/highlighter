<script lang="ts">
	import currentUser from '$stores/currentUser';
</script>

{#if $currentUser}
    <slot />
{:else}
    Please log in to view this page.
{/if}