<script lang="ts">
    import "../app.css";
    import { App } from 'konsta/svelte';
    import { KonstaProvider, Block, Button } from 'konsta/svelte';
</script>

<KonstaProvider theme="ios" dark={false}>
    <App theme="ios" class="k-ios" safeAreas={true}>
        <slot />
    </App>
</KonstaProvider>