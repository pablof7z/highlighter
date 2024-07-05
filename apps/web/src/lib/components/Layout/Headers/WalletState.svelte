<script lang="ts">
	import CurrentUser from "$components/CurrentUser.svelte";
	import { Lightning } from "phosphor-svelte";


</script>

<div class="flex items-center rounded-full w-[360px]">
    <CurrentUser class="w-16 h-16 rounded-full flex flex-row items-center" />
    <div class="flex items-center justify-between flex-grow bg-secondary w-full rounded-full p-2">
      <div class="flex items-center">
        <Lightning class="text-accent w-6 h-6" weight="fill" />
        <span class="text-white text-xl font-semibold">20.042</span>
      </div>
      <div class="relative w-10 h-10 flex items-center justify-center">
        <svg class="absolute top-0 left-0 w-full h-full transform rotate-90 text-blue-500" viewBox="0 0 36 36">
          <circle
            cx="18"
            cy="18"
            r="16"
            stroke="currentColor"
            stroke-width="4"
            fill="none"
            stroke-dasharray="100,100"
            stroke-dashoffset="8"
          ></circle>
        </svg>
        <span class="text-white text-base font-semibold">92</span>
      </div>
    </div>
  </div>
  