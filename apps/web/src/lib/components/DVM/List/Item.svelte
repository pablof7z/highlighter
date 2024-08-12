<script lang="ts">
	import { goto } from "$app/navigation";
	import Checkbox from "$components/Forms/Checkbox.svelte";
	import { Button } from "$components/ui/button";
	import Avatar from "$components/User/Avatar.svelte";
	import { ndk } from "$stores/ndk";
	import { NDKEvent, NDKKind, NDKUserProfile, NostrEvent } from "@nostr-dev-kit/ndk";

    export let dvm: NDKEvent;
    export let selected: boolean;
    let profile: NDKUserProfile;

    try {
        profile = JSON.parse(dvm.content) as NDKUserProfile;
    } catch (e) {
        console.error(e);
    }

    let status: string | undefined;

    async function tryDVM() {
        const req = new NDKEvent($ndk, {
            kind: 5300,
        } as NostrEvent);
        req.tag(dvm.author);
        if ($ndk.explicitRelayUrls) req.tags.push(["relays", ...$ndk.explicitRelayUrls]);
        req.tags.push(["output", "text/plain" ])
        await req.sign();

        const resp = $ndk.subscribe(req.filter());
        resp.on("event", (e) => {
            console.log("received "+e.kind+" "+e.content);

            if (e.kind === 7000) {
                status = e.content;
            } else if (e.kind === req.kind!+1000) {
                resp.stop();
                goto("/a/"+e.encode());
            }
        })
        resp.start();
        
        req.publish();
    }
</script>

{#if profile}
    <Checkbox bind:value={selected} type="switch">
        <div  class="flex flex-row gap-4 items-stretch p-2 w-full">
            <Avatar userProfile={profile} size="medium" />

            <div class="flex flex-col gap-0 5 grow">
                <div class="text-base text-foreground font-medium">
                    {profile.name}
                </div>

                <div class="text-sm text-muted-foreground">
                    {profile.about}
                </div>

                <Button variant="secondary" on:click={tryDVM}>
                    Try out
                </Button>
            </div>

        </div>

    </Checkbox>
{/if}
