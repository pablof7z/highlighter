<script lang="ts">
    import { NDKPrivateKeySigner } from '@nostr-dev-kit/ndk';
    // import { setupPlaceholderProfile } from './LoginModal/placeholder-profile';
    import {AttentionButton, ndk, user} from '@kind0/ui-common';

    async function loginAsGuest() {
        const pk = NDKPrivateKeySigner.generate();
        $ndk.signer = pk;
        $user = await $ndk.signer.user();

        localStorage.setItem('nostr-key-method', 'pk');
        localStorage.setItem('nostr-key', pk.privateKey!);
        localStorage.setItem('nostr-target-npub', $user.npub);

        // setupPlaceholderProfile();
    }
</script>

<AttentionButton handleClick={loginAsGuest}>
    <div class="flex items-center gap-2">
        <span >Continue as Guest</span>
    </div>
</AttentionButton>
