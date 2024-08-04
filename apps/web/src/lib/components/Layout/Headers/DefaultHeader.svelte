<script lang="ts">
    import CurrentUser from "$components/CurrentUser.svelte";
	import WalletState from "./WalletState.svelte";
	import NotificationsButton from "$components/PageElements/NotificationsButton.svelte";
	import currentUser from "$stores/currentUser";
</script>

<div class="flex flex-row items-center rounded-full grow gap-4 pt-[var(--safe-area-inset-top)]">
    <CurrentUser class="rounded-full flex flex-row items-center" />
    <WalletState />
    {#if $currentUser}
        <NotificationsButton />
    {/if}
</div>
