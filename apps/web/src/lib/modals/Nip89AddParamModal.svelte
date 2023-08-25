<script lang="ts">
	import { ModalWrapper } from "@kind0/ui-common";
	import type { Nip90Param } from "$utils/nip90";
	import { closeModal } from "svelte-modals";

    export let name: string = "";
    export let values: string = "";
    export let required: boolean = false;
    export let onSave: (name: string, param: Nip90Param) => void;
    export let onRemove: ((name: string) => void) | undefined = undefined;

    function save() {
        const param: Nip90Param = {
            required,
            values: values?.split(/[,\n]/).map(v => v.trim()).filter(v => v.length > 0)
        };

        onSave(name, param);

        name = "";
        required = false;
        values = "";
    }

    function remove() {
        if (onRemove)
            onRemove(name);
        closeModal();
    }
</script>

<ModalWrapper title="Add NIP-89 Parameter" bodyClass="flex flex-col gap-6">
    <div class="flex flex-col gap-2">
        <label>
            <span class="block">Name</span>
            <input type="text" class="input input-bordered w-full" bind:value={name} placeholder="Parameter this DVM accepts" autofocus />
            <span class="text-xs opacity-80">
                E.g. "model", "language"
            </span>
        </label>
    </div>

    <div class="flex flex-col gap-2">
        <label>
            <span class="block">Possible values processed by this DVM</span>
            <textarea class="textarea textarea-bordered w-full" bind:value={values} />
            <span class="text-xs opacity-80">
                E.g. "gpt3.5", "gpt4"
            </span>
        </label>
    </div>

    <div class="flex flex-row gap-2">
        <label>
            <input type="checkbox" class="checkbox checkbox-primary" bind:checked={required} />
            <span class="ml-2">Required</span>
        </label>
    </div>

    <div class="flex flex-row gap-2 justify-end border-t border-t-base-300 pt-8">
        <button class="btn btn-ghost" on:click={() => {save(); closeModal()}}>
            Save
        </button>

        <button class="btn btn-accent btn-outline px-10" on:click={save}>
            Save &amp; Add Another
        </button>

        <button
            class="btn btn-ghost"
            class:!btn-error={!!onRemove}
            on:click={remove}
        >
            {#if onRemove}
                Remove
            {:else}
                Cancel
            {/if}
        </button>
    </div>
</ModalWrapper>