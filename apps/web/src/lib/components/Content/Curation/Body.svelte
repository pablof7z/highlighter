<script lang="ts">
	import { layout } from "$stores/layout";
	import { NDKList } from "@nostr-dev-kit/ndk";
    import * as List from "$components/List";
    import * as Card from "$components/Card";
    import * as Feed from "$components/Feed";
    import Footer from './Footer.svelte';

    export let list: NDKList;

    $layout.header = undefined;
    $layout.title = list.title;
    $layout.iconUrl = list.image;
    $layout.navigation = false;
    $layout.fullWidth = false;
    $layout.footerInMain = true;
    $layout.footer = {
        component: Footer,
        props: { list },
    }

    $layout.sidebar = false;
    
    // $layout.sidebar = {
    //     component: Sidebar,
    //     props: { list },
    // }
</script>

<List.Root {list} let:items>
    <List.Shell orientation="vertical" {items} let:item>
        <Feed.Items.Article article={item} />
    </List.Shell>
</List.Root>