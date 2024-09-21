<script lang="ts">
    import { ndk } from "../../stores/ndk.js";
    import type { NDKSubscriptionOptions, NDKUser, NDKUserProfile } from '@nostr-dev-kit/ndk';
    import {Avatar} from '@nostr-dev-kit/ndk-svelte-components';

    export let pubkey: string | undefined = undefined;
    export let npub: string | undefined = undefined;
    export let user: NDKUser | undefined = undefined;
    export let userProfile: NDKUserProfile | undefined = undefined;
    export let subOpts: NDKSubscriptionOptions | undefined = undefined;
    export let size: 'xs' | 'tiny' | 'small' | 'medium' | "md" | 'lg' | 'large' | "unconstrained" = "small";
    export let type: 'square' | 'circle' = 'circle';
    export let ring = false;
    /**
     * Flag when the fetching is being done in a higher component
     **/
    export let fetching: boolean | undefined = undefined;

    let sizeClass = '';
    let shapeClass = '';

    let sizePx: number;

    switch (size) {
        case 'xs': sizePx = 16; break;
        case 'tiny': sizePx = 24; break;
        case 'small': sizePx = 26; break;
        case 'md': case 'medium': sizePx = 24; break;
        case 'lg': case 'large': sizePx = 32; break;
    }

    switch (type) {
        case 'circle':
            shapeClass = 'rounded-full';
            break;
        case 'square':
            shapeClass = 'rounded-sm';
            break;
    }

    if (fetching === undefined && !userProfile) {
        fetching = true;
        user ??= $ndk.getUser({npub, pubkey});
        user?.fetchProfile(subOpts).then((p) => {
            userProfile = p;
        }).catch((e) => {
            userProfile = null;
        }).finally(() => {
            fetching = false;
        });
    }

    let randSeed = Math.floor(Math.random() * 10) + 1;
</script>

{#if !userProfile && fetching}
    <img
        alt="Avatar loading..."
        src="https://api.dicebear.com/8.x/thumbs/svg?seed={user?.pubkey??randSeed}"
        class="
            {$$props.class}
            {$$props.loadingClass ? $$props.loadingClass : ""}
            {sizeClass} {shapeClass}
        "
        style='width: {sizePx}px; height: {sizePx}px; {$$props.loadingStyle??""}'
    />
{:else if userProfile || user || pubkey || npub}
    <div class="
        flex-none {sizeClass} {shapeClass}
        { ring ? "ring-4 ring-accent p-0.5" : "" }
    ">
        <Avatar
            ndk={$ndk}
            {pubkey}
            {npub}
            {user}
            {userProfile}
            class="flex-none object-cover {shapeClass} {$$props.class??""}"
            style='width: {sizePx}px; height: {sizePx}px;'
        />
    </div>
{/if}