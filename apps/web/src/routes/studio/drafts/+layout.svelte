<script lang="ts">
    import { page } from "$app/stores";
    import { layout } from "$stores/layout";

    let id: string;

    $: id = $page.url.search?.substring(1);

    $layout = {
        title: "Drafts",
        sidebar: false,
        back: { url: "/" },
        fullWidth: false
    }
</script>

<slot />