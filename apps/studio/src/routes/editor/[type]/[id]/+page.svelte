<script lang="ts">
	import { page } from '$app/stores';
	import * as Studio from '@components/Studio';

	const { type, id } = $page.params;
</script>

<Studio.Root {type} {id}></Studio.Root>
