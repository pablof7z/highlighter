<script lang="ts">
	import Badge from "$components/ui/badge/badge.svelte";
	import { notifications } from "$stores/notifications";
	import { roundedItemCount } from "$utils/numbers";

    let count: string | undefined;
    $: if ($notifications && $notifications.length > 0) {
        count = roundedItemCount($notifications);
    } else {
        count = undefined;
    }
</script>

<div class="relative {$$props.class??""}">
    <slot />
    {#if count}
        <Badge variant="accent" class="absolute top-0 right-0">
            {count}
        </Badge>
    {/if}
</div>