<script lang="ts">
	import { CaretRight } from "phosphor-svelte";
</script>

<ul class="w-full">
    <li>
        <a href="/settings/network">
            Network
            <CaretRight class="w-5 h-5" />
        </a>
    </li>

    <li>
        <a href="/settings/privacy">
            Privacy
            <CaretRight class="w-5 h-5" />
        </a>
    </li>
</ul>

<style>
    ul {
        @apply flex flex-col;
    }

    li a {
        @apply flex flex-row items-center justify-between;
        @apply py-2 text-lg;
    }

    li a:hover {
        @apply text-white;
    }

    li:not(:last-child) {
        @apply border-b-2 border-base-200;
    }

</style>