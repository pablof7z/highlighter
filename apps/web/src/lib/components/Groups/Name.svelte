<script lang="ts">
	import { GroupData } from '$components/Groups';
	import { ndk } from '$stores/ndk';
    export let group: GroupData;

    let name = group.name;

    // does this look like a pubkey?
    if (name && name?.length === 64) {
        try {
            const user = $ndk.getUser({ pubkey: name });
            if (user.npub) {
                user.fetchProfile().then((profile) => {
                    if (profile) name = profile.name;
                });
            }
        } catch {}
    }
</script>

{name}