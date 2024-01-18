<script lang="ts">
	import PageSidebar from "$components/PageSidebar.svelte";
	import { User } from "phosphor-svelte";

    let open = true;
</script>

<PageSidebar title="Highlights" bind:open>
    <a href="/highlights/my" class="flex flex-row gap-2 items-center">
        <User class="w-5 h-5" />
        My Highlights
    </a>
</PageSidebar>