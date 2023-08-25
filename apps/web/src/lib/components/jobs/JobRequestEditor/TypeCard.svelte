<script lang="ts">
	import { kindToText, kindToDescription } from "$utils";

    export let kind: number;

    let bg: string;

    switch (kind) {
        case 5000: bg = "!bg-primary text-primary-content"; break;
        case 5001: bg = "!bg-warning text-warning-content"; break;
        case 5002: bg = "!bg-info text-info-content"; break;
        case 5100: bg = "!bg-accent text-accent-content"; break;
        case 5300: bg = "!bg-accent2 text-accent-content"; break;
        case 5301: bg = "!bg-teal-400 text-black text-opacity-70"; break;
        case 5303: bg = "!bg-secondary text-secondary-content"; break;
    }
</script>

<button class="card !bg-opacity-80 {bg} hover:!bg-opacity-100 transition-all duration-50" on:click>
    <div class="card-body text-left items-start justify-stretch">
        <div class="card-title">{kindToText(kind)}</div>

        <p class="opacity-80">{kindToDescription(kind)}</p>
    </div>
</button>