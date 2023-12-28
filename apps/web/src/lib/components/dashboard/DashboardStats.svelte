<script lang="ts">
	import { getUserSupporters } from "$stores/user-view";
	import { ndk, user } from "@kind0/ui-common";
	import { onDestroy } from "svelte";

    const views = $ndk.storeSubscribe([
        { kinds: [15], "#p": [$user.pubkey] }
    ])

    const supporters = getUserSupporters();

    onDestroy(() => {
        views.unref();
    })
</script>

<div class="px-12 pt-4 pb-3 rounded-2xl border border-zinc-900 flex-col justify-center items-center gap-2 inline-flex">
    <div class="self-stretch justify-between items-center inline-flex">
        <div class="px-4 py-3 rounded-xl justify-start items-start gap-2 flex">
            <div class="flex-col justify-start items-center gap-2 inline-flex">
                <div class="text-white text-[21px] font-semibold leading-5">{$views.length}</div>
                <div class="text-white text-opacity-60 text-sm font-medium leading-5">Visits</div>
            </div>
        </div>
        <div class="px-4 py-3 rounded-xl justify-start items-start gap-2 flex hidden">
            <div class="flex-col justify-start items-center gap-2 inline-flex">
                <div class="text-white text-[21px] font-semibold leading-5">624</div>
                <div class="text-white text-opacity-60 text-sm font-medium leading-5">Subscribe Clicks</div>
            </div>
        </div>
        <div class="px-4 py-3 rounded-xl justify-start items-start gap-2 flex">
            <div class="flex-col justify-start items-center gap-2 inline-flex">
                <div class="text-white text-[21px] font-semibold leading-5">{$supporters.length??0}</div>
                <div class="text-white text-opacity-60 text-sm font-medium leading-5">Subscribed</div>
            </div>
        </div>
        <div class="px-4 py-3 rounded-xl justify-start items-start gap-2 flex">
            <div class="flex-col justify-start items-center gap-2 inline-flex">
                <div class="text-white text-[21px] font-semibold leading-5">1.9%</div>
                <div class="text-white text-opacity-60 text-sm font-medium leading-5">Subscribe Rate</div>
            </div>
        </div>
    </div>
</div>