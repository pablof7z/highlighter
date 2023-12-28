<script lang="ts">
	import Navbar from '$components/Navbar.svelte';
</script>

<svelte:head>
	<title>Faaans</title>
</svelte:head>

<Navbar class="!bg-transparent fixed z-40 !backdrop-blur-[0px]" maxSize="" />

<div class="hero min-h-screen relative" style="background-image: url(/images/landing-bg.jpg);">
	<div class="hero-overlay bg-black bg-opacity-40"></div>
	<div class="h-[517px] absolute left-0 w-full bottom-0 bg-gradient-to-b from-transparent to-black"></div>
	<div class="hero-content text-center text-neutral-content">
        <div class="w-full">
            <h1 class="mb-5 text-[calc(24px_+_5vw)]">A sanctuary for creativity</h1>
            <p class="mb-5 text-white text-[calc(12px_+_1vw)]">Own the relationship with your fans</p>
        </div>
	</div>
</div>

<div class="flex flex-col justify-start items-start gap-14 overflow-y-hidden w-full max-w-[100vw] px-4 -mx-4">
	<div class="flex-col justify-start items-start gap-12 flex w-full overflow-x-auto">
		<div class="w-full border border-white border-opacity-20"></div>
		<div class="text-white text-[32px] font-light">Formats</div>
	</div>
	<div class="justify-start items-center gap-16 flex w-full overflow-x-auto flex-nowrap">
		<div class="text-white text-[200px] font-light">Music</div>
		<div class="text-white text-[200px]">·</div>
		<div class="text-white text-[200px] font-light">Film</div>
		<div class="text-white text-[200px]">·</div>
		<div class="text-white text-[200px] font-light">Art</div>
		<div class="text-white text-[200px]">·</div>
		<div class="text-white text-[200px] font-light">Journalism</div>
	</div>
	<div class="w-full border border-white border-opacity-20"></div>
</div>

<div class="flex flex-col items-center">
    <section class="px-16 flex-col justify-start items-start gap-8 inline-flex mx-auto">
        <div class="self-stretch justify-start items-center gap-[88px] inline-flex">
            <div class="self-stretch flex-col justify-center items-start gap-12 inline-flex">
                <div class="self-stretch h-[171px] flex-col justify-center items-start gap-6 flex">
                    <div class="w-[624px] text-white text-5xl font-normal font-['Inter Display']">Support creators like Max DeMarco</div>
                    <div class="self-stretch text-white text-[26px] font-light font-['Inter Display']">An independent Filmmaker</div>
                </div>
                <div class="flex-col justify-center items-start gap-8 flex">
                    <div class="flex-col justify-center items-start gap-4 flex">
                        <div class="w-[312px] px-5 py-2.5 bg-white rounded-lg justify-center items-center gap-1.5 inline-flex">
                            <a class="button text-lg" href="/maxdemarco@nostrplebs.com">Support Max</a>
                        </div>
                    </div>
                    <div class="self-stretch h-[113px] flex-col justify-start items-start gap-1 flex">
                        <div class="self-stretch h-[113px] flex-col justify-start items-start gap-3 flex">
                            <div class="justify-start items-center gap-2 inline-flex">
                                <img class="w-11 h-11 rounded-full" src="/images/max.png" />
                                <div class="text-right text-white text-[15px] font-semibold font-['Inter Variable'] leading-snug">Seris Voidwalker</div>
                            </div>
                            <div class="self-stretch text-white text-opacity-60 text-sm font-normal font-['Inter Variable'] leading-[19px]">Your videos are truly inspirational and Nostr is lucky to have you as the official unofficial filmmaker!</div>
                        </div>
                    </div>
                </div>
            </div>
            <div class="w-[600px] h-[840px] bg-purple-500 bg-opacity-20 flex-col justify-center items-center inline-flex">
                <img class="w-[600px] h-[840px] object-cover object-top" src="/images/max.png" />
            </div>
        </div>
    </section>

    <div class="relative bg-black hidden">

        <div class="left-0 absolute flex-col justify-start items-start gap-[180px] inline-flex">
            <div class="self-stretch px-[120px] justify-start items-start gap-2 inline-flex">
            </div>
            <div class="flex-col justify-start items-center gap-[120px] flex">
                <div class="px-[120px] justify-start items-start gap-8 inline-flex">
                    <div class="pl-12 pr-[154.67px] pt-[523px] pb-12 bg-purple-500 bg-opacity-20 flex-col justify-end items-center inline-flex">
                        <div class="self-stretch flex-col justify-start items-start gap-8 inline-flex">
                            <div class="w-20 h-20 relative"></div>
                            <div class="flex-col justify-start items-start gap-4 flex">
                                <div class="text-white text-5xl">Max DeMarco</div>
                                <div class="text-center text-white text-[32px] font-light">Independent Filmmaker</div>
                            </div>
                        </div>
                    </div>
                    <div class="w-[538.67px] h-[799px] pl-[48.33px] pr-[312.33px] pt-12 pb-[635px] bg-green-950 bg-opacity-70 flex-col justify-start items-center inline-flex">
                        <div class="self-stretch flex-col justify-start items-start gap-4 inline-flex">
                            <div class="text-white text-5xl">Awayuki</div>
                            <div class="text-white text-[32px] font-light">Illustrator</div>
                        </div>
                    </div>
                    <div class="h-[799px] pl-[156.67px] pr-12 pt-[523px] pb-12 bg-stone-950 flex-col justify-end items-center inline-flex">
                        <div class="self-stretch flex-col justify-start items-end gap-8 inline-flex">
                            <div class="w-20 h-20 relative"></div>
                            <div class="flex-col justify-end items-end gap-4 flex">
                                <div class="text-white text-5xl">Man Like Kweks</div>
                                <div class="text-white text-[32px] font-light">Musician</div>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="px-12 py-6 bg-white rounded-[58px] justify-center items-center gap-2 inline-flex">
                    <div class="text-black text-[21px] font-semibold">Explore all creators</div>
                </div>
            </div>
            <div class="px-[120px] justify-center items-center gap-[120px] inline-flex">
                <div class="w-[780px] h-[1100px] relative bg-stone-950"></div>
                <div class="grow shrink basis-0 flex-col justify-start items-start gap-20 inline-flex">
                    <div class="self-stretch h-[0px] border border-white border-opacity-20"></div>
                    <div class="self-stretch h-[410px] flex-col justify-start items-start gap-16 flex">
                        <div class="text-white text-[32px] font-light">Creators</div>
                        <div class="self-stretch text-white text-[64px]">Multi-tiered custom subscriptions</div>
                        <div class="self-stretch text-white text-[32px] font-light">Create as many plans as you’d like so your work is enjoyed by people of all means and preferences.</div>
                    </div>
                    <div class="px-12 py-6 bg-white rounded-[58px] justify-center items-center gap-2 inline-flex">
                        <div class="text-black text-[21px] font-semibold">Create my page</div>
                    </div>
                </div>
            </div>
            <div class="px-[120px] justify-center items-center gap-[120px] inline-flex">
                <div class="grow shrink basis-0 flex-col justify-start items-start gap-20 inline-flex">
                    <div class="self-stretch h-[0px] border border-white border-opacity-20"></div>
                    <div class="self-stretch h-[410px] flex-col justify-start items-start gap-16 flex">
                        <div class="text-white text-[32px] font-light">Supporters</div>
                        <div class="self-stretch text-white text-[64px]">A beautiful feed with your latest content</div>
                        <div class="self-stretch text-white text-[32px] font-light">Inbox-style feed to see all of the creators and the content you subscribe to.</div>
                    </div>
                    <div class="px-12 py-6 bg-white rounded-[58px] justify-center items-center gap-2 inline-flex">
                        <div class="text-black text-[21px] font-semibold">Explore creators</div>
                    </div>
                </div>
                <div class="w-[780px] h-[1100px] relative bg-stone-950"></div>
            </div>
            <div class="px-[120px] justify-center items-center gap-[120px] inline-flex">
                <div class="w-[780px] h-[1100px] relative bg-stone-950"></div>
                <div class="grow shrink basis-0 flex-col justify-start items-start gap-20 inline-flex">
                    <div class="self-stretch h-[0px] border border-white border-opacity-20"></div>
                    <div class="self-stretch h-[410px] flex-col justify-start items-start gap-16 flex">
                        <div class="text-white text-[32px] font-light">Creative freedom</div>
                        <div class="self-stretch text-white text-[64px]">Own the relationship with your fans</div>
                        <div class="self-stretch text-white text-[32px] font-light">Powered by censorship-proof technology, with faaans, your fans are yours.</div>
                    </div>
                    <div class="px-12 py-6 bg-white rounded-[58px] justify-center items-center gap-2 inline-flex">
                        <div class="text-black text-[21px] font-semibold">How is this possible?</div>
                    </div>
                </div>
            </div>
            <div class="h-[1753px] px-[120px] flex-col justify-center items-center gap-[120px] flex">
                <div class="self-stretch h-[643px] flex-col justify-start items-start gap-20 flex">
                    <div class="self-stretch h-[0px] border border-white border-opacity-20"></div>
                    <div class="self-stretch h-[0px] flex-col justify-start items-start gap-12 flex">
                        <div class="self-stretch h-[0px] border border-white border-opacity-20"></div>
                    </div>
                    <div class="self-stretch h-[329px] flex-col justify-start items-start gap-16 flex">
                        <div class="text-white text-[32px] font-light">Powered by Lightning</div>
                        <div class="self-stretch text-white text-[64px]">Instant Payments</div>
                        <div class="w-[1546.66px] text-white text-[32px] font-light">Get paid the moment someone subscribes with bitcoin lightning payments. Near-zero fees, anywhere in the world. Or choose the convenience of traditional payment models.</div>
                    </div>
                    <div class="px-12 py-6 bg-white rounded-[58px] justify-center items-center gap-2 inline-flex">
                        <div class="text-black text-[21px] font-semibold">Create my page</div>
                    </div>
                </div>
                <div class="self-stretch justify-center items-center gap-[120px] inline-flex">
                    <div class="w-[780px] h-[990px] relative bg-stone-950"></div>
                    <div class="w-[780px] h-[840px] relative bg-stone-950"></div>
                </div>
            </div>
        </div>
        <div class="w-[1653.24px] h-[58px] left-[147px] top-[61px] absolute">
            <div class="w-[126.24px] h-[37.14px] left-0 top-[16.56px] absolute">
            </div>
            <div class="w-[402px] h-[58px] left-[1251.24px] top-0 absolute justify-start items-center gap-[123px] inline-flex">
                <div></div>
            </div>
        </div>
    </div>

    <section class="px-16 flex-col justify-center items-center gap-[100px] inline-flex">
        <div class="self-stretch h-[589px] flex-col justify-start items-start gap-16 flex">
            <div class="self-stretch h-[0px] border border-white border-opacity-20"></div>
            <div class="self-stretch h-[0px] flex-col justify-start items-start gap-12 flex">
                <div class="self-stretch h-[0px] border border-white border-opacity-20"></div>
            </div>
            <div class="self-stretch h-[343px] flex-col justify-start items-start gap-16 flex">
                <div class="self-stretch h-[343px] flex-col justify-start items-start gap-8 flex">
                    <div class="w-[239px] text-white text-[26px] font-light font-['Inter Display']">Powered by Nostr</div>
                    <div class="self-stretch text-white text-5xl font-normal font-['Inter Display']">Unified Social Media Presence</div>
                    <div class="lg:w-2/3 text-white text-[26px] font-light font-['Inter Display'] leading-[38px]">Creators have been splitting their social media into customer-acquisition silos (e.g. YouTube, Medium, Instagram) and monetization/community-building silos (Patreon, OnlyFans, Substack).<br/><br/></div>
                </div>
            </div>
            <div class="px-8 py-4 bg-white rounded-lg justify-center items-center gap-2 inline-flex">
                <a href="/about" class="text-black text-lg font-semibold font-['Inter Variable']">Read more about how Faaans is different</a>
            </div>
        </div>
    </section>

</div>