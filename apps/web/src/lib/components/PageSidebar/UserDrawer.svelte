<script lang="ts">
	import AvatarWithName from "$components/User/AvatarWithName.svelte";
import { logout } from "$utils/login";
	import { user } from "@kind0/ui-common";
	import { SignOut, SquaresFour } from "phosphor-svelte";


</script>

<ul class="menu menu-lg bg-base-200 rounded-box">
    <li>
        <AvatarWithName user={$user} class="" spacing="gap-4" nameClass="text-white font-semibold" />
    </li>
    <li><a href="/dashboard">
        <SquaresFour class="mr-2"/>
        Dashboard
    </a></li>
    <div class="divider my-0"></div>
    <li class=""><button on:click={logout} class="w-full">
        <SignOut class="mr-2"/>
        Log Out
    </button></li>
</ul>