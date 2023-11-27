<script lang="ts">
	import { Avatar, Name } from "@kind0/ui-common";
    import type { NDKEvent, NDKUser } from "@nostr-dev-kit/ndk";

    export let event: NDKEvent;
    export let user: NDKUser | undefined = event?.author;
</script>

<div class="w-[360px] px-6 pt-4 pb-6 rounded-3xl border border-neutral-800 flex-col justify-center items-start gap-4 inline-flex">
    <a href="/{user.npub}" class="justify-start items-center gap-4 inline-flex w-full">
        <Avatar {user} class="w-16 h-16 rounded-full border border-white" />
        <div class="text-white text-base font-semibold">
            <Name {user} class="w-11 h-11 rounded-full" />
        </div>
    </a>
    <button class="button w-full py-3">
        Faaan
    </button>
    <div class="flex-col justify-center items-start gap-3 flex">
        <div class="text-right text-neutral-500 text-base font-medium">152 Supporters</div>
        <div class="h-[721px] flex-col justify-start items-start gap-3 flex">
            <div class="self-stretch h-[105px] flex-col justify-start items-start gap-1 flex">
                <div class="justify-start items-center gap-2 inline-flex">
                    <img class="w-11 h-11 rounded-full" src="https://via.placeholder.com/44x44" />
                    <div class="text-right text-white text-base font-medium">Seris Voidwalker</div>
                </div>
                <div class="self-stretch text-white text-opacity-60 text-sm font-normal leading-[19px]">Your videos are truly inspirational and Nostr is lucky to have you as the official unofficial filmmaker!</div>
            </div>
            <div class="justify-start items-center gap-2 inline-flex">
                <img class="w-11 h-11 rounded-full" src="https://via.placeholder.com/44x44" />
                <div class="text-right text-white text-base font-medium">Lunara Spacewind</div>
            </div>
            <div class="justify-start items-center gap-2 inline-flex">
                <img class="w-11 h-11 rounded-full" src="https://via.placeholder.com/44x44" />
                <div class="text-right text-white text-base font-medium">Calyxia Moonshade</div>
            </div>
            <div class="justify-start items-center gap-2 inline-flex">
                <img class="w-11 h-11 rounded-full" src="https://via.placeholder.com/44x44" />
                <div class="text-right text-white text-base font-medium">Elara Galaxia</div>
            </div>
            <div class="justify-start items-center gap-2 inline-flex">
                <img class="w-11 h-11 rounded-full" src="https://via.placeholder.com/44x44" />
                <div class="text-right text-white text-base font-medium">Stella Voidstar</div>
            </div>
            <div class="justify-start items-center gap-2 inline-flex">
                <img class="w-11 h-11 rounded-full" src="https://via.placeholder.com/44x44" />
                <div class="text-right text-white text-base font-medium">Taela Cometra</div>
            </div>
            <div class="justify-start items-center gap-2 inline-flex">
                <img class="w-11 h-11 rounded-full" src="https://via.placeholder.com/44x44" />
                <div class="text-right text-white text-base font-medium">Nova Stardust</div>
            </div>
            <div class="justify-start items-center gap-2 inline-flex">
                <img class="w-11 h-11 rounded-full" src="https://via.placeholder.com/44x44" />
                <div class="text-right text-white text-base font-medium">Lyria Starshade</div>
            </div>
            <div class="justify-start items-center gap-2 inline-flex">
                <img class="w-11 h-11 rounded-full" src="https://via.placeholder.com/44x44" />
                <div class="text-right text-white text-base font-medium">Aurora Skydream</div>
            </div>
            <div class="justify-start items-center gap-2 inline-flex">
                <img class="w-11 h-11 rounded-full" src="https://via.placeholder.com/44x44" />
                <div class="text-right text-white text-base font-medium">Neoma Astrolyn</div>
            </div>
            <div class="justify-start items-center gap-2 inline-flex">
                <img class="w-11 h-11 rounded-full" src="https://via.placeholder.com/44x44" />
                <div class="text-right text-white text-base font-medium">Lysandra Stellara</div>
            </div>
            <div class="justify-start items-center gap-2 inline-flex">
                <div class="w-11 h-11 bg-zinc-800 rounded-full"></div>
                <div class="text-right text-white text-base font-medium">Anonymous</div>
            </div>
        </div>
    </div>
    <div class="w-[9px] h-7 bg-zinc-800 rounded-[28px]"></div>
</div>