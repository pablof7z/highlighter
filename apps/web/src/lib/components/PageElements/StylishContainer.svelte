<script lang="ts">
    export let border = 0;
</script>

<div class="w-full bg-gradient rounded-box" style="padding: {border}px;">
    <div class="rounded-box w-full bg-black/80 {$$props.class??""}">
        <slot />
    </div>
</div>