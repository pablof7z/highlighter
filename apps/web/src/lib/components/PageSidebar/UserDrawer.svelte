<script lang="ts">
	import AvatarWithName from "$components/User/AvatarWithName.svelte";
	import SignupModal from "$modals/SignupModal.svelte";
    import { logout } from "$utils/login";
	import { user } from "@kind0/ui-common";
	import { Gear, SignOut, SquaresFour, User } from "phosphor-svelte";
	import { openModal } from "svelte-modals";
    import SettingsMenu from "../Settings/Menu.svelte";
</script>

{#if $user}
    <SettingsMenu />
    <!-- <ul class="menu menu-lg bg-base-200 rounded-box">
        <li>
            <AvatarWithName user={$user} class="" spacing="gap-4" nameClass="text-white font-semibold" avatarType="square" />
        </li>
        <li><a href="/dashboard">
            <SquaresFour class="mr-2"/>
            Dashboard
        </a></li>
        <li><a href="/settings">
            <Gear class="mr-2"/>
            Settings
        </a></li>
        <div class="divider my-0"></div>
        <li class=""><button on:click={logout} class="w-full">
            <SignOut class="mr-2"/>
            Log Out
        </button></li>
    </ul> -->
{:else}
    <ul class="menu menu-lg bg-base-200 rounded-box">
        <li>
            <button on:click={() => openModal(SignupModal)}>
                <User class="mr-2"/>
                Sign Up
            </button>
        </li>
    </ul>
{/if}