<script lang="ts">
	import RadioButton from "$components/Forms/RadioButton.svelte";
	import BlankState from "$components/PageElements/BlankState.svelte";
	import { mobileNotifications } from "$stores/notifications";
	import { Badge } from "@capawesome/capacitor-badge";
    import { createEventDispatcher } from "svelte";

    const dispatcher = createEventDispatcher();

    let mode = 'yes';
    let denied = false;

    async function cont() {
        try {
        if (mode === "yes") {
            const perm = await Badge.requestPermissions();
            console.log({perm})
            if (perm.display === "denied") {
                denied = true;
            } else if (perm.display === "granted") {
                $mobileNotifications = true;
                Badge.set({count: 10})
            }
        } else {
            $mobileNotifications = false;
        }
    } catch (e) { console.error(e) }

        dispatcher("done", false);
    }
</script>

<BlankState
    cta="Continue"
    class="fixed w-full h-full top-0 left-0 flex flex-col items-center justify-center"
    on:click={cont}
>
    <img src="/images/drafts.png" class="mx-auto w-2/5 h-2/5 opacity-60 my-8" />
    <span class="text-2xl font-semibold">Slow alerts,<br/>timeless content.</span>
    <br>
    <span class="font-light text-muted-foreground">
        Want to receive notifications<br />
        from your favorite creators?
    </span>

    <div class="flex flex-col gap-1 my-4 w-full">
        <RadioButton
            bind:currentValue={mode}
            value="yes"
            class="whitespace-normal text-left h-fit p-4"
        >
            <div class="text-lg font-bold">Yes</div>
            <span slot="description" class="text-muted-foreground">
                Let me know when they publish and when someone responds to me
            </span>
        </RadioButton>
        <RadioButton
            bind:currentValue={mode}
            value="no"
        >
            No, I'll check manually
        </RadioButton>
    </div>
</BlankState>