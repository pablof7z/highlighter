<script lang="ts">
	import { layout } from "$stores/layout";

    $layout.fullWidth = true;
</script>

<div class="lg:p-6">
    <slot />
</div>