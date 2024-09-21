<script lang="ts">
	import { Input } from "$components/ui/input";
	import UserProfile from "$components/User/UserProfile.svelte";
	import currentUser from "$stores/currentUser";
	import { setLayout } from "$stores/layout";
	import { userProfile } from "$stores/session";
	import { NDKUserProfile } from "@nostr-dev-kit/ndk";

    setLayout({
        title: 'New Publication',
        fullWidth: false,
        back: { url: '/' }
    })

    let userProfile: NDKUserProfile;
    let name: string | undefined, picture: string | undefined, about: string | undefined;
    $: if (userProfile) {
        const n = userProfile.displayName ?? userProfile.name
        if (n) name = `${n}'s Highlighter`
        picture = userProfile.image;
        about = userProfile.about;
    }
</script>

<UserProfile bind:userProfile user={$currentUser} />

<div class="flex flex-col gap-6">
    <div class="flex flex-row items-start justify-between my-10">
        <div class="flex flex-col items-start">
            <h1 class="text-5xl font-bold mb-2">
                Publication
            </h1>
            <h3 class="font-light text-muted-foreground text-lg bg-secondary rounded-lg p-4 w-full">
                A place to manage all your content
            </h3>
        </div>
    </div>

    <Input
        label="Publication Name"
        placeholder="Enter the name of your publication"
        bind:value={name}
        class="text-xl p-4 h-auto"
    />
</div>