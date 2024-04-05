<script lang="ts">
    import { Crown, CrownSimple } from "phosphor-svelte";
import { SvelteComponent, createEventDispatcher } from "svelte";

    const dispatch = createEventDispatcher();

    type Option = {
        value?: string;
        name: string;
        tooltip?: string;
        icon?: any;
        class?: string;
        href?: string;
        id?: string;
        component?: {
            component: typeof SvelteComponent;
            props?: Record<string, any>;
        }
        fn?: () => void;
        premiumOnly?: boolean;
    };

    export let options: Option[] = [];

    export let value: string = "";
    export let name: string = "this user";

    function clicked(option: Option) {
        value = option.value || option.name
        if (option.fn) option.fn();

        dispatch('changed', { value, ...option });
    }
</script>

<div class="justify-start items-start inline-flex whitespace-nowrap max-sm:px-3 w-full">
    <div class="lg:justify-stretch lg:items-stretch items-end flex w-full {$$props.class??""}">
        {#each options as option (option.id ?? option.name)}
            {#if option.name === '-------'}
                <div class="
                    w-0.5 h-6 lg:w-full lg:h-[1px] bg-base-300 mx-2 lg:my-4
                "></div>
            {:else if option.component}
                <div class="max-lg:rounded-full transition-all duration-300 max-lg:hover:bg-white/10 p-1.5 items-center">
                    <div class="rounded-full p-[2px]" class:text-white={value === (option.value || option.name)}>
                        <svelte:component
                            this={option.component.component}
                            {...option.component.props??{}}
                        />
                    </div>
                </div>
            {:else}
                <div class="max-lg:rounded-full transition-all duration-300 max-lg:hover:bg-white/10 p-1.5 items-center">
                    <div class="rounded-full p-[2px]" class:text-white={value === (option.value || option.name)}>
                        <a
                            href={option.href}
                            class="
                                snap-center w-full {option.class??""}
                                px-4 sm:px-0 cursor-pointer
                                hover:text-white
                                {option.premiumOnly ? "premium" : ""}
                            "
                            on:click={() => clicked(option)}
                            class:active={value === (option.value || option.name)}
                        >
                            {#if option.icon}
                                <svelte:component this={option.icon} class="w-6 xl:w-5 h-6 xl:h-5 mr-1 inline" />
                            {/if}
                            <span class="sm:hidden lg:inline">
                                {option.name}
                                {#if option.premiumOnly}
                                    <span class="text-accent2">
                                        <CrownSimple class="ml-2 w-fit h-fit inline" weight="fill" />
                                    </span>
                                {/if}
                            </span>
                        </a>
                    </div>
                </div>
            {/if}
        {/each}
    </div>
</div>

<style>
    a {
        @apply justify-start items-center gap-2 flex;
        @apply text-neutral-400 text-sm font-normal;
        @apply transition-all duration-100;
        @apply text-lg;
    }

    a.active {
        @apply !bg-transparent !text-white font-bold;
    }
</style>