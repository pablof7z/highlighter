<script lang="ts">
    import { page } from "$app/stores";
    import EventViewerText from "$views/EventViewerPage/Text.svelte";

    let id: string;
    
    $: if (id !== $page.params.id) {
        id = $page.params.id;
    }
</script>

<EventViewerText {id} />
