<script lang="ts">
    import CloseIcon from '$lib/icons/Close.svelte';

    export let borderColor: string = "accent2";
    let hasFocus: boolean = false;

    async function toggleDropdown() {
        if (hasFocus) {
            // Close dropdown
            if (document.activeElement instanceof HTMLElement) {
                document.activeElement.blur();
                hasFocus = false;
            }
            return
        }
        hasFocus = true;
    }

</script>

<div class="dropdown {hasFocus ? 'dropdown-open': ''} dropdown-end">
    <label tabindex="0" on:click={toggleDropdown} >
        <div class="{hasFocus ? 'hidden' : 'transition duration-500 ease-out flex items-center'} transition">
            <slot name="dropdown-button" />
        </div>
        <div class={`${!hasFocus ? 'hidden' : ''} btn-close-outter btn-circle border border-${borderColor} grid place-items-center`}>
            <div class="btn-close-inner w-6 h-6 p-1 rounded-full">
                <CloseIcon />
            </div>
        </div>
    </label>
    <div tabindex="0" class="dropdown-content z-[1] mt-2">
        <slot />
    </div>
</div>
