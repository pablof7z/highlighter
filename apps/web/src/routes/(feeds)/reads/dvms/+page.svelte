<script lang="ts">
	import { NDKKind } from '@nostr-dev-kit/ndk';
    import * as DVM from "$components/DVM";

</script>

<DVM.List.Container kind={NDKKind.DVMReqDiscoveryNostrContent} let:dvm>
    <DVM.List.Item {dvm} />
</DVM.List.Container>