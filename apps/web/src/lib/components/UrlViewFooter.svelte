<script lang="ts">
	import * as Footer from "$components/Footer";
    import { NDKArticle } from "@nostr-dev-kit/ndk";
    import Curate from '$components/Footer/Views/Curate';
	import { scrollPercentage } from '$stores/layout';
    import { Progress } from "$lib/components/ui/progress";
	import HighlightTool from '$components/Footer/Views/HighlightTool';
	import { FooterView } from '$components/Footer';
	import HighlightViewer from '$components/Footer/Views/HighlightViewer';
	import Share from '$components/Footer/Views/Share';
	import Comment from '$components/Footer/Views/Comment';

    export let article: NDKArticle;
    export let placeholder = "Reply";

    const defaultViews: FooterView[] = [
        {...HighlightTool, props: { event: article }},
        {...HighlightViewer, props: { article }},
        {...Comment, props: { event: article, placeholder: 'Comment...' }},
    ];

    let open: Footer.OpenFn;
    let views: FooterView[] | undefined = defaultViews;
</script>

<Footer.Shell
    bind:open
    {views}
>
    <div class="absolute top-0 left-0 h-1 right-0">
        <Progress value={$scrollPercentage} class="rounded-sm h-1" barClass="dark:bg-gold light:bg-foreground" />
    </div>

    <div slot="main">
        <div class="grid grid-cols-3 lg:grid-cols-5 gap-2">

            <Share.LargeButton {open} event={article} />
            <Curate.LargeButton {open} />
        </div>
    </div>
</Footer.Shell>