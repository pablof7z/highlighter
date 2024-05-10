<script lang="ts">
	import { layoutMode, layoutNavState } from "$stores/layout";

    $layoutNavState = "collapsed";
	$layoutMode = "single-column-focused";
</script>

<slot />