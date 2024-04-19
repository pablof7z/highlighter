<script lang="ts">
	import AvatarWithName from "$components/User/AvatarWithName.svelte";
	import SignupModal from "$modals/SignupModal.svelte";
    import { logout } from "$utils/login";
    import currentUser from "$stores/currentUser";
	import { Fire, Gear, House, PaperPlane, SignOut, SquaresFour, User } from "phosphor-svelte";
	import { openModal } from "svelte-modals";
    import SettingsMenu from "../Settings/Menu.svelte";
	import Item from "$components/PageElements/Navigation/Item.svelte";
	import NewItemModal from "$modals/NewItemModal.svelte";

    let authorUrl: string;
</script>

{#if $currentUser}
    <ul class="menu menu-lg bg-base-200 rounded-box">
        <li>
            <AvatarWithName user={$currentUser} bind:authorUrl nameClass="text-xl text-white font-semibold"
                spacing="gap-4"
                avatarSize="large" avatarClass="w-16 h-16"
            >
            <div class="flex md:flex-row flex-col gap-4 items-stretch justify-evenly w-full">
                <a href={authorUrl} class="button button-black sm:w-1/3 text-xs whitespace-nowrap">
                    View Profile
                </a>
                <a href="/settings/profile" class="button button-black sm:w-1/3 text-xs whitespace-nowrap">
                    Edit Profile
                </a>
                <button class="button button-black sm:w-1/3 text-xs whitespace-nowrap" on:click={logout}>
                    Log out
                </button>
            </div>
            </AvatarWithName>

        </li>
        <li><a href="/dashboard">
            <SquaresFour class="mr-2"/>
            Dashboard
        </a></li>
        <li><a href="/home">
            <House class="mr-2"/>
            Home
        </a></li>
        <li>
            <button on:click={() => openModal(NewItemModal)}
            >
                <PaperPlane class="mr-2" />
                Publish
            </button>
        </li>
        <li><a href="/settings">
            <Gear class="mr-2"/>
            Settings
        </a></li>
        <div class="divider my-0"></div>
        <li class=""><button on:click={logout} class="w-full">
            <SignOut class="mr-2"/>
            Log Out
        </button></li>
    </ul>
{:else}
    <ul class="menu menu-lg bg-base-200 rounded-box">
        <li>
            <button on:click={() => openModal(SignupModal)}>
                <User class="mr-2"/>
                Sign Up
            </button>
        </li>

        <li>
            <a href="/">
                <Fire class="mr-2"/>
                Explore Nostr
            </a>
        </li>
    </ul>
{/if}