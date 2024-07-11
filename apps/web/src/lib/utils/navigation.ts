import type { NavigationOption } from '../../app.d.js';
import { writable } from 'svelte/store';

export class Navigation {
    options = writable<NavigationOption[]>([]);
    existingOptions = new Set<string>();

    setOption(name: string, option: NavigationOption, eosed?: boolean, prepend = false) {
        const alreadyExists = this.existingOptions.has(name);
        if (!eosed && alreadyExists) return;
        if (!eosed) delete option.badge;

        let insertIndex = -1;
        let optionsArray: NavigationOption[] = [];
        this.options.subscribe(value => {
            optionsArray = value;
        })();

        // If the option already exists, find its index and remove it
        if (alreadyExists) {
            insertIndex = optionsArray.findIndex(o => o.id === name);
            optionsArray = optionsArray.filter(o => o.id !== name);
        }

        // Insert the option at the correct position
        if (insertIndex !== -1 && !prepend) {
            optionsArray = [...optionsArray.slice(0, insertIndex), option, ...optionsArray.slice(insertIndex)];
        } else {
            if (prepend) {
                optionsArray = [option, ...optionsArray];
            } else {
                optionsArray = [...optionsArray, option];
            }
        }

        this.existingOptions.add(name);
        this.options.set(optionsArray);
    }
}
