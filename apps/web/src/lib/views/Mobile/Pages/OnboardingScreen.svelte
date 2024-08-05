<script lang="ts">
	import { Sun } from 'phosphor-svelte';
	import Nostr from '$icons/nostr.svelte';
	import { onMount } from 'svelte';
	import Button from "$components/ui/button/button.svelte";
	import LogoSmall from "$icons/LogoSmall.svelte";
    import { register } from 'swiper/element/bundle';
	import { toggleMode } from 'mode-watcher';
	import { createGuestAccount } from '$utils/user/guest';
    
    onMount(() => {
        register();
    })
    
    let activeIndex = 0;
    let swiper: any;

    function onSlideChange(e) {
        activeIndex = e.detail.actievIndex;
        console.log(swiper);
    }

    function signup() {
        createGuestAccount();
    }
</script>

<div class="flex flex-col h-full w-full fixed top-0 bottom-0 left-0 right-0 justify-center items-center">
    <swiper-container
        class="h-full w-full" freemode pagination="true" indicators="true" mousewheel="true"
        on:swiperslidechange={onSlideChange}
        bind:this={swiper}
    >
        <swiper-slide>
            <div class="h-1/3"></div>
            
            <LogoSmall class="w-1/3" />
            
            <h1>Welcome</h1>

            <p class="text-lg font-serif w-4/5 text-muted-foreground text-center grow">
                Highlighter is a
                calm place for
                <span class="text-foreground">content creators</span>
                to build long-lasting relationships with their audience.
            </p>
        </swiper-slide>

        <swiper-slide>
            <div class="flex flex-col items-center justify-center w-4/5">
                <Nostr class="w-1/3" />
                
                <h1>Built on nostr</h1>

                <div class="text-lg font-serif text-muted-foreground grow flex flex-col gap-4">
                    <p>A censorship-resistant protocol without a blockchain or any kind of token.</p>

                    <p>
                        What you publish through Highlighter is yours forever.
                    </p>

                    <p>
                        No editors or algorithms to hinder your reach, nor shape your thought.
                    </p>
                </div>
            </div>


        </swiper-slide>
    </swiper-container>

    <div class="self-end w-full py-10 grid grid-cols-3 gap-4 responsive-padding">
        <Button variant="outline" size="lg" >Skip</Button>

        <Button class="w-full col-span-2" size="lg" on:click={signup} href="/mobile/onboarding/account-type">
            Get started
        </Button>

        <Button variant="outline" size="lg" class="col-span-3" href="/mobile/onboarding/login?mode=login">
            I already have a nostr account
        </Button>
    </div>
</div>

<style lang="postcss">
    swiper-slide {
        @apply h-full w-full flex flex-col items-center justify-center;
    }
</style>