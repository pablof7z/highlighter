<script lang="ts">
	import AvatarWithName from "$components/User/AvatarWithName.svelte";
	import { NDKKind, type NDKEvent, type NDKUserProfile } from "@nostr-dev-kit/ndk";
	import type { UserProfileType } from "../app";
	import { ndk } from "@kind0/ui-common";

    export let dvm: NDKEvent | undefined = undefined;
    export let event: NDKEvent | undefined = undefined;
    export let dvmUser = dvm?.author ?? event!.author;

    if (!dvm && event) {
        $ndk.fetchEvent({
            kinds: [NDKKind.AppHandler],
            "#k": [event.kind!.toString()]
        }).then((e) => {
            if (e) dvm = e;
            else {
                event?.author.fetchProfile().then(u => {
                    if (u) profile = u;
                });
            }
        })
    }

    let profile: UserProfileType | null;

    $: if (dvm) {
        try {
            profile = JSON.parse(dvm.content);
        } catch {
            dvm.author.fetchProfile().then(u => profile = u);
        }
    }
</script>

{#if profile}
    <li>
        <AvatarWithName user={dvmUser} userProfile={profile} />
    </li>
{/if}