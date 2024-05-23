<script lang="ts">
    import ModalShell from "$components/ModalShell.svelte";
    import AvatarWithName from "$components/User/AvatarWithName.svelte";
    import { RelativeTime, ndk } from "@kind0/ui-common";
    import { Check } from "phosphor-svelte";
    import { closeModal } from '$utils/modal';

    export let action: string = "Post will be published";
    // async function
    export let onSchedule: (timestamp: number) => Promise<void>;

    // make this configurable
    const dvmUser = $ndk.getUser({npub: 'npub1shpq6dmqaa8pjas8rftflvmr7nlssm9fqanflw23vlxu2vzexngslu90nm'});

    let publishAtVal: string | undefined;
    let publishAt: number | undefined = Date.now() + 1000 * 60 * 60;
    publishAtVal = new Date(publishAt).toISOString().slice(0, 16);

    $: if (publishAtVal) {
        try {
            const date = new Date(publishAtVal);
            if (date.getTime() > Date.now()) { publishAt = date.getDate(); }
        } catch(e) { publishAt = undefined }
    }

    function setTime(minutes: number) {
        return () => {
            publishAt = Date.now() + minutes * 60 * 1000;
            // publishAtVal = new Date(publishAt).toISOString().slice(0, 16);
        }
    }

    function setRelativeTime(inXDays: number, atYHour: number) {
        return () => {
            const date = new Date();
            date.setDate(date.getDate() + inXDays);
            date.setHours(atYHour, 0, 0, 0);
            publishAt = date.getTime();
            // publishAtVal = date.toISOString().slice(0, 16);
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
</script>

<ModalShell color="glassy" class="" title="Schedule Boost" on:close>
    <div class="flex flex-col w-full text-sm border-b border-base-300 items-center pb-4">
        <div class="flex flex-row items-center gap-2 justify-center ">
            Scheduling provided by
            <AvatarWithName user={dvmUser} avatarType="circle" avatarSize="small" class="text-base-100-content" />
        </div>
        <a href="/settings/services" class="text-xs underline">Configure a different provider</a>
    </div>

    {#if scheduled}
        <div class="flex flex-col items-center gap-4">
            <span class="text-2xl text-accent2">
                <Check class="w-12 h-12 text-success" />
            </span>
            <span class="text-xl text-base-100-content">Scheduled!</span>
        </div>
    {:else}
        <ul class="menu w-full">
            <li><button on:click={setTime(60)}>In an hour</button></li>
            <li><button on:click={setTime(60*3)}>In 3 hours</button></li>
            <li><button on:click={setTime(60*8)}>In 8 hours</button></li>
            <li><button on:click={setTime(60*24)}>In 24 hours</button></li>
            <li><button on:click={setRelativeTime(1, 9)}>Tomorrow 9am</button></li>
            <li><button on:click={setTime(60*24*7)}>Next week</button></li>
        </ul>

        <div class="flex flex-row gap-2">
            <input type="datetime-local" bind:value={publishAtVal} class="input rounded-full !bg-white/5" />
        </div>

        {#if publishAt}
            <span class="text-sm text-base-100-content/50">
                {action}
                <RelativeTime timestamp={publishAt} class="text-base-100-content" />
            </span>
        {/if}

        <div class="flex flex-row gap-2 w-full justify-end">
            <button class="btn btn-ghost" on:click={() => closeModal()}>
                Cancel
            </button>

            <button class="button grow" on:click={schedule} {disabled}>
                {#if scheduling}
                    <span class="loading loading-sm"></span>
                {:else}
                    Schedule
                {/if}
            </button>
        </div>
    {/if}
</ModalShell>