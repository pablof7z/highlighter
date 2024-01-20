<script lang="ts">
	import PageSidebar from "$components/PageSidebar.svelte";
	import { CaretRight } from "phosphor-svelte";


</script>

<PageSidebar title="Settings">
    <ul class="w-full">
        <li>
            <a href="/settings?network">
                Network
                <CaretRight class="w-5 h-5" />
            </a>
        </li>

        <li>
            <a href="/settings?network">
                Privacy
                <CaretRight class="w-5 h-5" />
            </a>
        </li>
    </ul>
</PageSidebar>

<style>
    ul {
        @apply flex flex-col;
    }

    li a {
        @apply flex flex-row items-center justify-between;
        @apply py-2;
    }

    li a:hover {
        @apply text-white;
    }

    li:not(:last-child) {
        @apply border-b-2 border-base-200;
    }

</style>