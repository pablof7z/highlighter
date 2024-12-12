<script lang="ts">
    import * as Editor from "@/components/Editor";
	import { currentUser } from "@/state/current-user.svelte";
	import { Button } from "@/components/ui/button";
	import { CaretDown } from "svelte-radix";
	import Avatar from "@/components/user/Avatar.svelte";
	import { appState } from "@/state/app.svelte";
	import { wrapEvent } from "@highlighter/common";
    import { Checkbox } from "@components/ui/checkbox/index.js";
    import { Label } from "@components/ui/label/index.js";
	import { ndk } from "@/state/ndk";
	import { NDKEvent, NDKKind, type NostrEvent } from "@nostr-dev-kit/ndk";
	import { toast } from "svelte-sonner";
	import { type ButtonStatus } from "@/components/ui/button/button.svelte";
	import { goto } from "$app/navigation";
	import AvatarWithName from "@/components/user/AvatarWithName.svelte";

    let checked = $state(false);

    if (!appState.activeEvent!) {
        goto('/');
    }
    
    const event = $derived(wrapEvent(appState.activeEvent!));
    
    const user = $derived.by(currentUser);
    
    let content = $state(`I just published a new read:\n${event.title}\nnostr:${appState.activeEvent!.encode()}\nCheck it out!`);

    let status = $state<ButtonStatus>("initial");
    async function post() {
        status = "loading";

        try {
            const e = new NDKEvent(ndk, {
                kind: NDKKind.Text,
                content: content,
                tags: [
                    [ "q", ...appState.activeEvent!.tagId() ]
                ]
            } as NostrEvent);
            await e.publish();
            status = "success";

            toast.success("Post published", {
                description: "Your post has been published to the Nostr network.",
                duration: 10000,
                action: {
                    label: "View on Nostr",
                    onClick: () => {
                        window.open(`https://njump.me/${e.encode()}`, '_blank');
                    }
                }
            });
        } catch (e: any) {
            status = "error";
            toast.error(e.message);
        } finally {
            status = "initial";
        }
    }
</script>

<div class="hidden space-y-6 pb-16 md:block">
	<div class="container py-6">
		<h2 class="text-4xl font-medium tracking-tight text-center">
            Your article is live. Well done!
        </h2>
		<p class="text-muted-foreground text-center text-xl mb-10 font-extralight mt-2">
			You've done the work. Now it's time to reap the rewards.
		</p>

        <div class="flex flex-col border border-border rounded-lg mx-auto gap-4 bg-muted/10">
            <div class="flex flex-col items-start gap-4 w-full p-4">
                
                
                <AvatarWithName of={user} size="small" avatarSize="small" nameClass="text-muted-foreground text-xs" />
            
                <Editor.Root
                    bind:content
                    markdown={false}
                    skipToolbar
                    placeholder="Share as a nostr note..."
                    className="min-h-[50px] text-muted-foreground"
                />
            </div>  

            <div class="flex flex-row items-center justify-between border-t border-border px-4 py-3 bg-muted/30">
                <div class="flex items-center space-x-2">
                    <Checkbox id="terms" bind:checked aria-labelledby="terms-label" />
                    <Label
                      id="terms-label"
                      for="terms"
                      class="text-sm font-normal text-muted-foreground leading-none peer-disabled:cursor-not-allowed peer-disabled:opacity-70"
                    >
                        Target multiple timezones
                    </Label>
                </div>
                
                <div class="flex flex-row items-center gap-4">
                    <!-- <Button variant="ghost" size="sm">
                        Templates
                        <CaretDown class="w-4 h-4 ml-2" />
                    </Button> -->
                    
                    <Button size="sm" class="px-6" onclick={post} {status}>
                        Post
                    </Button>
                </div>
            </div>
        </div>
    </div>
</div>

<style lang="postcss">
    .container {
        @apply max-w-2xl mx-auto;
    }
</style>