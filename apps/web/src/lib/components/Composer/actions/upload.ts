import { Writable } from "svelte/store";
import { State } from "..";

export default async function (
    state: Writable<State>,
) {
    state.update(s => {
        s.forceFileUpload = true;
        return s;
    });
}