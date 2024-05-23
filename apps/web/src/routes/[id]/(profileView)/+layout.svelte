<script lang="ts">
	import CreatorShell from '$components/Creator/CreatorShell.svelte';
	import { page } from "$app/stores";
	import { ndk } from "@kind0/ui-common";
	import { resetLayout } from '$stores/layout';
	import { onDestroy } from 'svelte';

    let id: string;
    let { user } = $page.data;

    $: if (id !== $page.params.id) {
        id = $page.params.id;
        user.ndk = $ndk;
    }

    onDestroy(resetLayout);

</script>

{#key user.pubkey}
    <CreatorShell {user}>
        <slot />
    </CreatorShell>
{/key}