<script lang="ts">
    import ndk from '$lib/stores/ndk';
    import LoginNip07Button from './LoginNip07Button.svelte';
    import LoginGuestButton from './LoginGuestButton.svelte';
    // import LoginNip46Button from './LoginNip46Button.svelte';
    import CollapsableDropdown from '$lib/components/CollapsableDropdown.svelte';
</script>

{#if !$ndk.signer}
    <CollapsableDropdown>
        <!-- dropdown-button can not be <button> element. Issue with daisyUI dropdown -->
        <div slot="dropdown-button" class="btn btn-outline btn-rounded-full rounded-full border-accent2 bg-transparent text-base-100-content text-sm md:text-base normal-case hover:border-accent2 hover:bg-accent2 hover:bg-opacity-20 hover:text-base-100-content">
            <span class="px-0 md:px-4 lg:px-9">
                Log In
            </span>
        </div>

        <ul class="divide-y divide-neutral-800 menu p-0 w-60 rounded-box">
            <div>
                <div class="flex justify-center menu-title">
                    <div class="p-1 text-center text-base font-medium text-base-100-content">Log In</div>
                </div>
            </div>
            <div class="p-4">
                <div class="flex flex-col items-start px-4">
                    <div class="text-xs text-base">
                        Highlighter is a tool built using the <span class="text-accent2">Nostr Protocol</span>, which means you can login using keys
                        instead of a centralized identity provider.
                    </div>
                </div>
            </div>
            <div class="p-4">
                <div class="flex justify-center">
                    <div class="flex flex-col gap-2 w-full">
                        <div class="text-center text-xs font-normal">New to all this?</div>
                        <LoginGuestButton />
                    </div>
                </div>
            </div>
            <div class="p-4">
                <div class="flex justify-center">
                    <div class="flex flex-col gap-2 w-full">
                        <div class="text-center text-xs font-normal">Already on Nostr?</div>
                        <LoginNip07Button />
                        <!-- <LoginNip46Button /> -->
                    </div>
                </div>
            </div>
        </ul>

    </CollapsableDropdown>
{/if}
