<script lang="ts">
    import * as Studio from "$components/Studio";
	import { layout } from "$stores/layout";

    $layout.title = "Studio";
    $layout.navigation = false;
    $layout.sidebar = false;
</script>

<Studio.Root let:groups>
    <Studio.Shell {groups}>
        <slot />
    </Studio.Shell>
</Studio.Root>