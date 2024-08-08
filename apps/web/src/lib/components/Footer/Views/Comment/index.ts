import { Writable, writable } from "svelte/store";
import Button from "./Button.svelte";
import Toolbar from "./Toolbar.svelte";
import LargeButton from "./LargeButton.svelte";
import View from "./View.svelte";
import * as Composer from "$components/Composer";

const name = 'comment';

export type State = {
    state?: Writable<Composer.State>;
    actions?: Composer.Actions;
}

export default {
    name,
    Button,
    Toolbar,
    LargeButton,
    View,

    createStateStore: () => writable<State>({})
}