<script lang="ts">
	import Navbar from '$components/Navbar.svelte';
	import { ndk } from '@kind0/ui-common';

	const supporters = $ndk.storeSubscribe([
		{ kinds: [7001 as number] },
	], { subId: 'subscribers' });
</script>

<svelte:head>
	<title>Faaans</title>
</svelte:head>

<Navbar class="!bg-transparent fixed z-50" />

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

<div class="flex-col justify-start items-start gap-14 inline-flex px-32 w-full max-w-screen overflow-hidden ">
	<div class="flex-col justify-start items-start gap-12 flex w-full">
		<div class="w-full border border-white border-opacity-20"></div>
		<div class="text-white text-[32px] font-light">Formats</div>
	</div>
	<div class="justify-center items-center gap-16 inline-flex w-screen overflow-x-hidden">
		<div class="text-white text-[200px] font-light">Music  </div>
		<div class="text-white text-[200px]">·</div>
		<div class="text-white text-[200px] font-light">Film</div>
		<div class="text-white text-[200px]">·</div>
		<div class="text-white text-[200px] font-light">Art</div>
		<div class="text-white text-[200px]">·</div>
		<div class="text-white text-[200px] font-light">Journalism</div>
	</div>
	<div class="w-full border border-white border-opacity-20"></div>
</div>

<div class="relative bg-black">

    <div class="left-0 absolute flex-col justify-start items-start gap-[180px] inline-flex">
        <div class="self-stretch px-[120px] justify-start items-start gap-2 inline-flex">
        </div>
        <div class="h-[993px] flex-col justify-start items-center gap-[120px] flex">
            <div class="h-[799px] px-[120px] justify-start items-start gap-8 inline-flex">
                <div class="h-[799px] pl-12 pr-[154.67px] pt-[523px] pb-12 bg-purple-500 bg-opacity-20 flex-col justify-end items-center inline-flex">
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
