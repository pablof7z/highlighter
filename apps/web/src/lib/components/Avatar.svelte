<script lang="ts">
    import ndk from '$lib/stores/ndk';
    import type { NDKUser } from '@nostr-dev-kit/ndk';
    import {Avatar} from '@nostr-dev-kit/ndk-svelte-components';

    export let pubkey: string | undefined = undefined;
    export let user: NDKUser | undefined = undefined;
    export let klass: string = $$props.class??'';
    export let size: 'small' | 'large' | undefined = undefined;
    export let type: 'square' | 'circle' = 'circle';

    let sizeClass = '';
    let shapeClass = '';

    switch (size) {
        case 'small':
            sizeClass = 'w-8 h-8';
            break;
    }

    switch (type) {
        case 'circle':
            shapeClass = 'rounded-full';
            break;
        case 'square':
            shapeClass = 'rounded-md';
            break;
    }
</script>

<Avatar
    ndk={$ndk}
    {pubkey}
    {user}
    class="{shapeClass} {sizeClass} {$$props.class??klass}"
/>