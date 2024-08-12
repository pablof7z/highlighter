<script lang="ts">
	import { layout } from "$stores/layout";
	import { NDKList } from "@nostr-dev-kit/ndk";
    import * as List from "$components/List";
    import * as Card from "$components/Card";
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
        <div class="px-2 flex flex-col gap-2 pb-6">
            <Card.FeaturedArticle article={item} />
            <!-- <List.Item {item} /> -->
        </div>
    </List.Shell>
</List.Root>