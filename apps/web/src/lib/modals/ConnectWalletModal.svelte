<script lang="ts">
	import ModalShell from "$components/ModalShell.svelte";
</script>

<ModalShell>
    <div class="w-[380px] h-[497px] px-10 pt-6 pb-10 bg-white rounded-3xl justify-start items-start gap-8 inline-flex">
        <div class="grow shrink basis-0 flex-col justify-start items-start gap-6 inline-flex">
            <div class="self-stretch h-[71px] flex-col justify-start items-center gap-3 flex">
                <div class="flex-col justify-start items-start gap-4 flex">
                    <div class="justify-start items-center gap-3 inline-flex">
                        <div class="w-10 h-10 relative">
                            <div class="w-10 h-10 left-0 top-0 absolute bg-white rounded-full"></div>
                            <img class="w-10 h-10 left-0 top-0 absolute" src="https://via.placeholder.com/40x40" />
                            <div class="w-10 h-10 left-0 top-0 absolute rounded-full border-2 border-black"></div>
                        </div>
                        <div class="text-black text-lg font-medium font-['Outfit']">Andre Jones</div>
                    </div>
                </div>
                <div class="text-black text-sm font-medium font-['Outfit'] leading-[19px]">8,209 sats /mo (~$3)</div>
            </div>
            <div class="self-stretch text-center text-black text-base font-normal font-['Outfit'] leading-normal">Connect a lightning wallet to subscribe to Andre’s content.</div>
            <div class="self-stretch h-[266px] flex-col justify-start items-center gap-3 flex">
                <div class="self-stretch h-11 flex-col justify-start items-center gap-[8.30px] flex">
                    <div class="self-stretch h-11 flex-col justify-center items-start gap-4 flex">
                        <div class="self-stretch px-6 py-3 bg-zinc-950 rounded-[58px] justify-center items-center gap-2 inline-flex">
                            <div class="text-white text-base font-semibold font-['Outfit']">Connect with Alby</div>
                        </div>
                    </div>
                </div>
                <div class="self-stretch h-11 flex-col justify-center items-start gap-4 flex">
                    <div class="self-stretch px-6 py-3 bg-zinc-950 rounded-[58px] justify-center items-center gap-2 inline-flex">
                        <div class="text-white text-base font-semibold font-['Outfit']">Connect with Mutiny</div>
                    </div>
                </div>
                <div class="self-stretch justify-center items-center gap-3 inline-flex">
                    <div class="grow shrink basis-0 h-[0px] border border-neutral-200"></div>
                    <div class="text-zinc-400 text-sm font-normal font-['Outfit'] leading-[19px]">OR</div>
                    <div class="grow shrink basis-0 h-[0px] border border-neutral-200"></div>
                </div>
                <div class="self-stretch h-[123px] flex-col justify-start items-start gap-1.5 flex">
                    <div class="w-72 text-black text-base font-medium font-['Outfit'] leading-normal">Nostr Wallet Connect</div>
                    <div class="self-stretch h-[93px] flex-col justify-start items-start gap-1.5 flex">
                        <div class="self-stretch px-4 py-3 bg-white rounded-[100px] shadow border border-neutral-200 justify-start items-center gap-2 inline-flex">
                            <div class="grow shrink basis-0 text-black text-opacity-30 text-base font-normal font-['Outfit'] leading-[19px]">Wallet connect URL / pairing secret</div>
                        </div>
                        <div class="self-stretch px-6 py-3 bg-black rounded-[58px] justify-center items-center gap-2 inline-flex">
                            <div class="text-white text-base font-semibold font-['Outfit']">Connect</div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</ModalShell>