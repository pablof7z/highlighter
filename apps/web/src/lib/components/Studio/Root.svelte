<script lang="ts">
	import currentUser from "$stores/currentUser";
    import * as User from "$components/User";
</script>

{#if $currentUser}
    <User.Root
        user={$currentUser}
        let:groups
    >
        <slot {groups} />
    </User.Root>
{/if}