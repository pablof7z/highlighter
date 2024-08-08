import { writable } from "svelte/store";
import Button from "./Button.svelte";
import Toolbar from "./Toolbar.svelte";

const name = 'zap-prompt';

export type State = {
    seen?: boolean;
}

export default {
    name,
    Button,
    Toolbar,
    createStateStore: () => writable<State>({})
}