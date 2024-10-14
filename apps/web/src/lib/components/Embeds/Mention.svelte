<svelte:options customElement="ndk-event-mention" />
<script lang="ts">
	import Name from '$components/User/Name.svelte';
	import { ndk } from '$stores/ndk';

    export let npub: string;

    const user = $ndk.getUser({ npub });
</script>

<a href={`/${npub}`} class="text-accent underline">
    @<Name {user} />
</a>