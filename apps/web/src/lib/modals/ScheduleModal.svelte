<script lang="ts">
    import ModalShell from "$components/ModalShell.svelte";
    import { ndk } from "$stores/ndk.js";
    import { Check } from "phosphor-svelte";
	import Button from "$components/ui/button/button.svelte";
	import { NavigationOption } from "../../app";
    import * as DropdownMenu from "$lib/components/ui/dropdown-menu/index.js";
	import Avatar from "$components/User/Avatar.svelte";
	import Name from "$components/User/Name.svelte";
	import { Input } from "$components/ui/input";
	import RelativeTime from "$components/PageElements/RelativeTime.svelte";

    export let title = "Schedule Boost";
    export let action: string = "Post will be published";
    // async function
    export let onSchedule: (timestamp: number) => Promise<void>;
    export let cta = "Schedule";

    // make this configurable
    const dvmUser = $ndk.getUser({npub: 'npub1shpq6dmqaa8pjas8rftflvmr7nlssm9fqanflw23vlxu2vzexngslu90nm'});

    let publishAtVal: string | undefined;
    let publishAt: number | undefined = Date.now() + 1000 * 60 * 60;
    publishAtVal = new Date(publishAt).toISOString().slice(0, 16);

    $: if (publishAtVal) {
        try {
            const date = new Date(publishAtVal);
            console.log({date})
            publishAt = date.getTime();
        } catch(e) { publishAt = undefined }
    }

    function setTime(minutes: number) {
        return () => {
            publishAt = Date.now() + minutes * 60 * 1000;
            publishAtVal = new Date(publishAt).toISOString().slice(0, 16);
        }
    }

    function setRelativeTime(inXDays: number, atYHour: number) {
        return () => {
            const date = new Date();
            date.setDate(date.getDate() + inXDays);
            date.setHours(atYHour, 0, 0, 0);
            publishAt = date.getTime();
            publishAtVal = date.toISOString().slice(0, 16);
        }
    }

    let disabled = false;

    $: disabled = !publishAt || publishAt < Date.now();

    export let scheduling = false;
    export let scheduled = false;

    function schedule() {
        scheduling = true;
        if (!publishAt) return;

        onSchedule(publishAt).then(() => {
            scheduled = true;
            scheduling = false;
        });
    }

    let actionButtons: NavigationOption[];
    
    $: actionButtons = [
        { name: cta, fn: schedule, buttonProps: {disabled}, buttonProps: { variant: 'accent', size: 'lg' } }
    ]
</script>

<ModalShell
    {title} on:close
    class="max-w-sm w-full"
    {actionButtons}
>
    <div class="flex" slot="footerExtra">
        <DropdownMenu.Root>
            <DropdownMenu.Trigger>
                <Button variant="outline" size="sm" class="flex flex-row items-center gap-1 text-xs">
                    <Avatar user={dvmUser} type="circle" size="tiny" />
                    via <Name user={dvmUser} />
                </Button>
            </DropdownMenu.Trigger>

            <DropdownMenu.Content class="absolute z-[999999]">
                <DropdownMenu.Group>
                    <Button variant="ghost" href="/settings/services">Configure a different provider</Button>
                </DropdownMenu.Group>
            </DropdownMenu.Content>
        </DropdownMenu.Root>
    </div>

    {#if scheduled}
        <div class="flex flex-col items-center gap-4">
            <span class="text-2xl text-accent">
                <Check class="w-12 h-12 text-green-500" />
            </span>
            <span class="text-xl text-foreground">Scheduled!</span>
        </div>
    {:else}
        <ul class="w-full">
            <li><button on:click={setTime(60)}>In an hour</button></li>
            <li><button on:click={setTime(60*3)}>In 3 hours</button></li>
            <li><button on:click={setTime(60*8)}>In 8 hours</button></li>
            <li><button on:click={setTime(60*24)}>In 24 hours</button></li>
            <li><button on:click={setRelativeTime(1, 9)}>Tomorrow 9am</button></li>
            <li><button on:click={setTime(60*24*7)}>Next week</button></li>
        </ul>

        <div class="flex flex-col gap-2 p-1 mt-6">
            <Input type="datetime-local" class="justify-center text-lg font-light" bind:value={publishAtVal} />

            {#if action}
                <span class="text-sm text-muted-foreground">
                    {action}
                    <RelativeTime timestamp={publishAt} class="text-foreground" />
                </span>
            {/if}
        </div>
    {/if}
</ModalShell>

<style lang="postcss">
    ul {
        @apply flex flex-col border border-border border-b-0;
    }

    li {
        @apply flex flex-row border-b border-border;
    }

    button {
        @apply text-foreground text-sm font-light w-full px-4 py-2 text-left;
        @apply hover:bg-secondary;
    }
</style>