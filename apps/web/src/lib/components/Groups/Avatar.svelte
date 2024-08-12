<script lang="ts">
	import { GroupData } from ".";

    export let group: GroupData;
    export let size: 'xs' | 'tiny' | 'small' | 'medium' | 'large' | undefined = undefined;

    let width: number;
    let height: number;

    switch (size) {
        case 'xs':
            width = 16;
            height = 16;
            break;
        case 'tiny':
            width = 24;
            height = 24;
            break;
        default:
        case 'small':
            width = 32;
            height = 32;
            break;
        case 'medium':
            width = 48;
            height = 48;
            break;
        case 'large':
            width = 64;
            height = 64;
            break;
    }
</script>

<img
    src={group.picture}
    class="rounded-full"
    style="width: {width}px; height: {height}px;"
    alt="Group avatar"
/>