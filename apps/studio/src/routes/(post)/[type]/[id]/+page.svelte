<script lang="ts">
	import { page } from '$app/stores';
	import PostRoot from '@components/Post/Root.svelte';

	const { type, id } = $page.params;
</script>

<PostRoot {type} {id} />
