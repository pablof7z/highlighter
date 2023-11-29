<script lang="ts">
	import type { NDKUser, NDKUserProfile } from "@nostr-dev-kit/ndk";

    export let user: NDKUser;
    let profile: NDKUserProfile | undefined | null = undefined;

    user.fetchProfile().then((p) => profile = p);

    let link = `/${user.npub}`;

    $: if (profile?.nip05) link = `/${profile.nip05}`;
</script>

<div class="min-w-[300px] flex-col justify-center items-center gap-6 inline-flex">
<div class="text-black text-[21px] font-medium">Thank you for your support!</div>
    <img src="/images/thank-you.png" />
    <div class="self-stretch h-[42px] flex-col justify-start items-center gap-3 flex">
        <div class="self-stretch h-[42px] flex-col justify-start items-center gap-3 flex">
            <div class="self-stretch h-[42px] flex-col justify-start items-center gap-[8.30px] flex">
                <div class="self-stretch h-[42px] flex-col justify-center items-start gap-4 flex">
                    <a href={link} class="button button-primary w-full">
                        See content
                    </a>
                </div>
            </div>
        </div>
    </div>
</div>