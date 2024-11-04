<script lang="ts">
	import { ndk } from '$stores/ndk';

    export let hashtag: string;
</script>

<a href={`/t/${hashtag}`} class="text-foreground">
    {hashtag}
</a>