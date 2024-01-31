<script lang="ts">
	import AvatarWithName from "$components/User/AvatarWithName.svelte";
	import { NDKKind, type NDKEvent, type NDKUserProfile } from "@nostr-dev-kit/ndk";
	import type { UserProfileType } from "../app";
	import { ndk } from "@kind0/ui-common";

    export let dvm: NDKEvent | undefined = undefined;
    export let event: NDKEvent | undefined = undefined;
    export let dvmUser = dvm?.author ?? event!.author;
    let fetching: boolean = true;

    if (!dvm && event) {
        $ndk.fetchEvent({
            kinds: [NDKKind.AppHandler],
            "#k": [event.kind!.toString()]
        }).then((e) => {
            if (e) {
                dvm = e;
                fetching = false;
            } else {
                event?.author.fetchProfile().then(u => {
                    if (u) {
                        dvmProfile = u;
                    }
                }).finally(() => {
                    fetching = false;
                });
            }
        })
    }

    let dvmProfile: UserProfileType | null;

    $: if (dvm) {
        try {
            dvmProfile = JSON.parse(dvm.content);
        } catch {
            dvmUser.fetchProfile().then(u => dvmProfile = u);
        }
    }
</script>

{#if dvmProfile}
    <slot {dvmProfile} {fetching} />
{/if}