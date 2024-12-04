<script lang="ts">
    import { Hexpubkey, NDKEvent, NDKUser } from "@nostr-dev-kit/ndk";

	import ModalShell from "$components/ModalShell.svelte";
	import { nip19 } from "nostr-tools";
	import AvatarWithName from "$components/User/AvatarWithName.svelte";
	import { searchUser } from "$utils/search/user";
	import { userFollows } from "$stores/session";
	import { ndk } from "$stores/ndk";
	import { UserSearchResult } from "$utils/search";
	import { debounce } from "@sveu/shared";
	import { closeModal } from "$utils/modal";
	import { NavigationOption } from "../../app";
	import EventWrapper from "$components/Feed/EventWrapper.svelte";
	import { UserCircleCheck } from "phosphor-svelte";
    
    export let title = "Search for users or events";
    export let onSelect: (nip19encoding: string) => void;
    
    let searchTerm = "";
    let results: UserSearchResult[] = [];

    const debouncedSearch = debounce(searchUser, 0.1);

    let selectedEncoding: string | undefined = undefined;
    
    let selectedIndex = -1;

    let event: NDKEvent | null | undefined = undefined;

    async function tryToLoadFromNip19() {
        try {
            const res = nip19.decode(searchTerm);

            // it worked, so we'll take it
            selectedEncoding = searchTerm;

            if (res.type === "npub") {
                const user = $ndk.getUser({pubkey: res.data});
                results = [{
                    id: user.pubkey,
                    user,
                    profile: null,
                    followed: $userFollows.has(user.pubkey) 
                }];
                user.fetchProfile()
                    .then(profile => {
                        results = [{
                            id: user.pubkey,
                            user,
                            profile: profile ?? null,
                            followed: $userFollows.has(user.pubkey) 
                        }];
                    });
            } else if (['naddr', 'note', 'nevent'].includes(res.type)) {
                $ndk.fetchEvent(searchTerm)
                    .then(e => {
                        event = e;
                    });
            }
 
            return true;
        } catch {
            event = undefined;
            selectedEncoding = undefined;
        }

        return false;
    }

    $: if (searchTerm) {
        tryToLoadFromNip19()
            .then(success => {
                if (success) return;

                debouncedSearch(searchTerm, $ndk, $userFollows)
                    .then(res => {
                        console.log("res", res);
                        results = res ?? [];
                    });
            });
    } else reset()

    function reset() {
        event = undefined;
        results = [];
        selectedEncoding = undefined;
    }

    $: if (selectedIndex >= 0 && itemRefs[selectedIndex]) {
        itemRefs[selectedIndex].scrollIntoView({ block: 'nearest', behavior: 'smooth' });
    }

    function setPubkey(pubkey: Hexpubkey) {
        const user = $ndk.getUser({pubkey});
        selectedEncoding = user.nprofile;
    }

    function callback() {
        if (!selectedEncoding) {
            console.log("no selectedEncoding");
            return;
        }
        onSelect(selectedEncoding);
        closeModal();
    }

    function handleKeydown(event: KeyboardEvent) {
        if (event.key === 'ArrowDown') {
            event.preventDefault();
            selectedIndex = (selectedIndex + 1) % results.length;
            console.log("selectedIndex", selectedIndex);
            const result = results[selectedIndex];
            if (result?.pubkey) setPubkey(result.pubkey!);
            else {
                console.log("no pubkey", result, selectedIndex);
            }
        } else if (event.key === 'ArrowUp') {
            event.preventDefault();
            selectedIndex = (selectedIndex - 1 + results.length) % results.length;
            console.log("selectedIndex", selectedIndex);
            const result = results[selectedIndex];
            if (result?.pubkey) setPubkey(result.pubkey!);
            else {
                console.log("no pubkey", result, selectedIndex);
            }
        } else if (event.key === 'Enter') {
            event.preventDefault();
            if (selectedEncoding) callback();
        } else if (event.key === 'Escape') {
            closeModal();
        }
    }

    let actionButtons: NavigationOption[];
    
    $: actionButtons = [
        {
            name: "Cancel",
            buttonProps: { variant: "secondary" },
            fn: () => closeModal()
        },
        {
            name: "Insert",
            buttonProps: { variant: "default", disabled: !selectedEncoding },
            fn: () => callback()
        }
    ];

    let itemRefs: HTMLElement[] = [];
</script>

<ModalShell {title}
    {actionButtons}
class="h-[50vh] transition-all duration-300 w-full flex flex-col {event ? 'max-w-3xl' : 'max-w-xl'}">
    <div class="flex flex-col h-full overflow-y-auto">
    <input
        type="text"
        bind:value={searchTerm}
        on:keydown={handleKeydown}
        placeholder="Search users or enter a note, nevent, or naddr"
        autofocus
        class="w-full p-2 border rounded-md mb-4"
    />
    
    <div class="space-y-2 flex-1 grow border border-border rounded-lg bg-seconday overflow-y-auto">
        {#if event}
            <EventWrapper {event} compact skipFooter skipZaps />
        {:else}
            {#each results.slice(0, 50) as result, index (result.pubkey)}
                <button
                    bind:this={itemRefs[index]}
                    class="flex flex-row gap-4 items-center w-full text-left hover:bg-secondary p-2 {index === selectedIndex ? 'bg-secondary' : ''}"
                    on:click={() => {
                        setPubkey(result.pubkey);
                        callback();
                    }}
                >
                    <AvatarWithName pubkey={result.pubkey} userProfile={result.profile} />
                    {#if result.followed}
                        <UserCircleCheck class="w-4 h-4 text-secondary" />
                    {/if}
                </button>
            {/each}
        {/if}
        </div>
    </div>  
</ModalShell>