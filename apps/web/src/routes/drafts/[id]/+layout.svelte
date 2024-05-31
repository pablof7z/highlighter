<script lang="ts">
    import { page } from "$app/stores";

    let id: string;

    $: id = $page.url.search?.substring(1);
</script>

<slot />