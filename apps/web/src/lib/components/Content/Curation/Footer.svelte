<script lang="ts">
	import * as Footer from "$components/Footer";
    import Zap from '$components/Footer/Views/Zap';
    import Curate from '$components/Footer/Views/Curate';
	import { FooterView } from '$components/Footer';
	import Share from '$components/Footer/Views/Share';
	import Comment from '$components/Footer/Views/Comment';
	import { NDKList } from "@nostr-dev-kit/ndk";

    export let list: NDKList;

    let zapped = false;

    function onZapped() {
        zapped = true;
    }

    const defaultViews: FooterView[] = [
        {...Zap, buttonProps: { zapped }, props: { event: list, onZapped }},
        {...Comment, props: { event: list, placeholder: 'Comment on this curation' }},
    ];

    let open: Footer.OpenFn;
    let views: FooterView[] | undefined = defaultViews;
</script>

<Footer.Shell
    bind:open
    {views}
>
    <div slot="main">
        <div class="grid grid-cols-3 lg:grid-cols-5 gap-2">
            <Share.LargeButton {open} event={list} />
            <Zap.LargeButton {open} />
            <Curate.LargeButton {open} />
        </div>
    </div>
</Footer.Shell>