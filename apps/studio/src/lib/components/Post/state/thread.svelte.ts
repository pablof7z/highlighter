import { PostState } from "./index.svelte";

export class ThreadState extends PostState {
    type = 'thread';
    notes = $state<string[]>([]);
    
    constructor() {
        super();
    }

    validate() {
        const errors = super.validate();
        if (this.notes.length === 0) errors.push('missing-content');
        return errors;
    }
}
