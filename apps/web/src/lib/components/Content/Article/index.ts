import Header from './Header.svelte';
import Body from './Body.svelte';
import Footer from './Footer.svelte';
import Shell from './Shell.svelte';

export type ArticleSettings = {
    highlights: {
        byUser: boolean;
        byNetwork: boolean;
        outOfNetwork: boolean;
    }
};

export {
    Header,
    Body,
    Footer,
    Shell
};