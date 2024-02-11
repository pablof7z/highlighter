<script lang="ts">
	import Checkbox from "$components/Forms/Checkbox.svelte";
	import { makePublicAfter } from "$stores/post-editor";

    let makeFreeCheck = $makePublicAfter !== undefined && Number($makePublicAfter) > 0;

    $: if (!makeFreeCheck) $makePublicAfter = false;

    function updateMakePublic() {
        if ($makePublicAfter === undefined || $makePublicAfter === false) {
            makeFreeCheck = false;
        } else {
            makeFreeCheck = true;
        }
    }
</script>

<Checkbox
    bind:value={makeFreeCheck}
    button={true}
    class="bg-white/5 !text-neutral-300 font-normal col-span-3 grow w-full"
    on:change={() => {
        if (makeFreeCheck) $makePublicAfter = 7
        else $makePublicAfter = false
    }}
>
    Release full-version for free after

    <select slot="button" class="select rounded-full text-black self-center text-base bg-neutral-200 pl-4 py-0 min-h-0 h-10" bind:value={$makePublicAfter} on:change={updateMakePublic}>
        <option value={false}>never</option>
        <option value={1}>1 day</option>
        <option value={7}>1 week</option>
        <option value={14}>2 weeks</option>
        <option value={30}>1 month</option>
    </select>
</Checkbox>