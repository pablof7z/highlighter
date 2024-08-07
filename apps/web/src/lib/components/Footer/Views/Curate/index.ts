import { writable } from "svelte/store";
import LargeButton from "./LargeButton.svelte";
import Toolbar from "./Toolbar.svelte";
import View from "./View.svelte";

const name = 'curation';

export type State = {
    showNew?: boolean;
    forceSaveNewCollection?: boolean;
    forceSaveCollections?: boolean;
    save?: boolean;
}

// create component View and attach the state store as a prop and export it

export default {
    name,
    View,
    LargeButton,

    Toolbar,
    createStateStore: () => writable<State>({})
}