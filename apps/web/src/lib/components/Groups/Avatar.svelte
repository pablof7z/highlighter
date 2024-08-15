<script lang="ts">
	import { ndk } from "$stores/ndk";
	import { GroupData } from ".";

    export let group: GroupData;
    export let size: 'xs' | 'sm' | 'small' | 'medium' | 'large' | undefined = undefined;

    let width: number;
    let height: number;

    switch (size) {
        case 'xs':
            width = 16;
            height = 16;
            break;
        case 'sm':
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

    let name = group.name;
    let src = group.picture;

    // does this look like a pubkey?
    if (name && name?.length === 64) {
        try {
            const user = $ndk.getUser({ pubkey: name });
            if (user.npub) {
                user.fetchProfile().then((profile) => {
                    if (profile?.image) src = profile.image;
                });
            }
        } catch {}
    } else {
        if (!src) {
            group.metadata?.author.fetchProfile().then((profile) => {
                if (profile?.image) src ??= profile.image;
            });

            // get the first admin's image
            const firstAdmin = group.admins?.members[0];
            if (firstAdmin) {
                $ndk.getUser({pubkey: firstAdmin}).fetchProfile().then((profile) => {
                    if (profile?.image) src = profile.image;
                });
            }
        }
    }
</script>

<img
    {src}
    class="rounded-full {$$props.class??""}"
    style="width: {width}px; height: {height}px;"
    alt="Group avatar"
/>