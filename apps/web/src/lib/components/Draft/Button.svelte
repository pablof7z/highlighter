<script lang="ts">
	import { beforeNavigate } from "$app/navigation";
    import * as Tooltip from "$lib/components/ui/tooltip";
	import { onDestroy } from "svelte";
    
    export let shouldSave: (() => Promise<boolean>) | undefined = undefined;
    export let save: (manuallySaved: boolean) => Promise<boolean>;
    export let timer: number | undefined = undefined;

    let timeout: NodeJS.Timeout | number | undefined = undefined;

    let manuallySaved = false;
    enum State {
        Unsaved = '',
        Saving = 'Saving Changes',
        Saved = 'Draft',
        // RecentlySaved = 'Saved',
        Failed = 'Failed to save'
    }
    let state: State = State.Unsaved;

    const saved = () => {
        state = State.Saved;
        // setTimeout(() => { state = State.Saved; }, 1000);
    }

    beforeNavigate(({cancel}) => {
        autoSave();
        // if (state === State.Saving) {
        //     cancel();
        // }   
    });
    
    onDestroy(() => {
        if (timeout) {
            clearTimeout(timeout as number);
        }
    });

    const autoSave = async () => {
        if (state === State.Saving) return;

        if (shouldSave && await shouldSave() === false) {
            timeout = setTimeout(autoSave, timer! * 1000);
            return;
        }

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

        timeout = setTimeout(autoSave, timer! * 1000);
    }

    if (timer) {
        timeout = setTimeout(autoSave, timer * 1000);
    }

    async function click() {
        manuallySaved = true;
        state = State.Saving;

        try {
            if (await save(manuallySaved)) {
                saved();
            } else {
                console.error("Failed to save");
                state = State.Failed;
            }
        } catch (e) {
            console.error(e);
            state = State.Failed;
        }
    }

    let indicatorClass: 'success' | 'failed' | 'unknown' = 'unknown';

    $: switch (state) {
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

            <span class="w-24 text-left">
                {state}
            </span>
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