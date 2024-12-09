import { NDKArticle } from '@nostr-dev-kit/ndk';

export class ReactiveArticle extends NDKArticle {
    content = $state('');
    private _title = $state('');
    private _summary = $state('');

    

    get title() {
        return this._title;
    }

    set title(value: string) {
        this._title = value;
    }

    get summary() {
        return this._summary;
    }

    set summary(value: string) {
        this._summary = value;
    }
}
