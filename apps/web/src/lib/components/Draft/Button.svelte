<script lang="ts">
    import * as Tooltip from "$lib/components/ui/tooltip";
    
    export let save: (manuallySaved: boolean) => Promise<boolean>;
    export let timer: number | undefined = undefined;

    let manuallySaved = false;
    enum State {
        Unsaved = 'Draft',
        Saving = 'Saving Changes',
        Saved = 'Draft',
        RecentlySaved = 'Draft - Changes saved',
        Failed = 'Failed to save'
    }
    let state: State = State.Unsaved;

    const saved = () => {
        state = State.RecentlySaved;
        setTimeout(() => { state = State.Saved; }, 2000);
    }

    const autoSave = async () => {
        if (state === State.Saving) return;

        manuallySaved = false;
        state = State.Saving;

        try {
            if (await save(manuallySaved)) {
                saved();
            } else {
                state = State.Failed;
            }
        } catch (e) {
            console.error(e);
            state = State.Failed;
        }

        setTimeout(autoSave, timer! * 1000);
    }

    if (timer) {
        setTimeout(autoSave, timer * 1000);
    }

    async function click() {
        manuallySaved = true;
        state = State.Saving;

        if (await save(manuallySaved)) {
            saved();
        } else {
            console.error("Failed to save");
        }
    }

    export let lastSave: number | undefined = undefined;
    let saveAgo: number | undefined = undefined;

    setInterval(() => {
        if (lastSave) {
            saveAgo = Math.floor((Date.now() - lastSave) / 1000);
        }
    }, 1000);

    let indicatorClass: 'success' | 'failed' | 'unknown' = 'unknown';

    $: switch (state) {
        case State.RecentlySaved:
        case State.Saved:
            indicatorClass = 'success';
            break;
        case State.Failed:
            indicatorClass = 'failed';
            break;
        case State.Unsaved:
            indicatorClass = 'unknown';
            break;
    }
</script>

<Tooltip.Root>
    <Tooltip.Trigger>
        <button class="text-muted-foreground/80 text-xs transition-all duration-500 flex flex-row items-center gap-2  {$$props.class??""}" on:click={click}>
            <div class="rounded-full w-2 h-2 {indicatorClass}"></div>

            {state}
        </button>
    </Tooltip.Trigger>
    <Tooltip.Content>
        Save Draft
    </Tooltip.Content>
</Tooltip.Root>

<style lang="postcss">
    .success {
        @apply bg-green-500;
    }

    .failed {
        @apply bg-red-500;
    }

    .unknown {
        @apply bg-muted-foreground;
    }
</style>