import { Writable } from "svelte/store";
import { ComposerState } from "..";

export default async function (
    state: Writable<ComposerState>,
) {
    state.update(s => {
        s.forceFileUpload = true;
        return s;
    });
}