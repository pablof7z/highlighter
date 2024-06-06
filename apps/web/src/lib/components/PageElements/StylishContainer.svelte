<script lang="ts">
    export let border = 0;
    export let backgroundOpacity = 0.8;
</script>

<div class="w-full bg-gradient rounded" style="padding: {border}px;">
    <div class="rounded w-full bg-black {$$props.class??""}" style="background: rgba(0, 0, 0, {backgroundOpacity});">
        <slot />
    </div>
</div>