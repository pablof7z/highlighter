<script lang="ts">
	import CreatorShell from '$components/Creator/CreatorShell.svelte';
	import { page } from "$app/stores";
	import { ndk } from "@kind0/ui-common";
	import { pageMainContentMaxWidth, resetLayout } from '$stores/layout';
	import { onDestroy } from 'svelte';

    let id: string;
    let { user } = $page.data;

    $: if (id !== $page.params.id) {
        id = $page.params.id;
        user.ndk = $ndk;
    }

    $pageMainContentMaxWidth = 'max-w-3xl';

    onDestroy(resetLayout);

</script>

<CreatorShell {user}>
    <slot />
</CreatorShell>
