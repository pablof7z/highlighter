import { writable } from "svelte/store";
import Button from "./Button.svelte";
import View from "./View.svelte";

const name = 'explore';

export type State = {
    search?: string;
    onKeyDown?: (e: KeyboardEvent) => void;
}

export default {
    name,
    Button,
    Toolbar: Button,
    View,

    createStateStore: () => writable<State>({ search: ""})
}