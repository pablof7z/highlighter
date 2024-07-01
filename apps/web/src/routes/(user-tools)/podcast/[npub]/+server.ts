import { ndk } from '$stores/ndk.js';
import { NDKEvent } from '@nostr-dev-kit/ndk';
import { text } from '@sveltejs/kit';
import { Podcast } from 'podcast';
import { get } from 'svelte/store';

const timeout = (ms: number) => new Promise<void>((resolve) => setTimeout(resolve, ms));

export async function GET({ url, params }) {
    const $ndk = get(ndk);
    const { npub } = params;

    console.log('npub', npub);

    console.log('fetching user');

    const user = $ndk.getUser({npub});
    const profile = await user.fetchProfile();
    console.log('profile', profile);

    const feed = new Podcast({
        title: "Highlighter for " + profile?.displayName,
        imageUrl: "https://highlighter.com/images/icon.png",
        siteUrl: "https://highlighter.com",
        author: "Highlighter"
    });

    // use HEAD to get the length of the file in https://pblsw.ngrok.io/podcast/npub1l2vyh47mk2p0qlsku7hg0vn29faehy9hy34ygaclpn66ukqp3afqutajft
    // const req = await fetch('https://pblsw.ngrok.io/podcast/npub1l2vyh47mk2p0qlsku7hg0vn29faehy9hy34ygaclpn66ukqp3afqutajft', {
    //     method: 'HEAD',
    // });

    console.log('fetching events');

    const results = await $ndk.fetchEvents({ kinds: [6250 as number], "#p": [user.pubkey]}, { groupable: false});
    console.log('results', results.size);
    
    const promises: Promise<any>[] = [];

    for (const event of Array.from(results)) {
        // validate it's a url
        try {
            new URL(url);
        } catch (e) {
            console.log('invalid url', url);
            continue;
        }

        promises.push(new Promise<void>(async (resolve) => {
            let author: string | undefined;
            let title: string | undefined;
            let description: string | undefined;
            let imageUrl: string | undefined;
            const url = event.content;
            let date = new Date(event.created_at!*1000).toLocaleDateString();

            await Promise.race([
                timeout(1500),
                new Promise<void>(async (resolve) => {
                    let request: NDKEvent;

                    try {
                        request = new NDKEvent($ndk, JSON.parse(event.tagValue("request")!));
                        title = request.tagValue("title");
                        description = request.tagValue("summary");

                        if (title) resolve();
                    } catch {}
                    
                    const inputTag = event.tagValue("i");
                    if (!inputTag) { resolve(); return; }

                    $ndk.fetchEvent(inputTag).then(async (inputEvent) => {
                        if (!inputEvent) { resolve(); return; }

                        inputEvent.author.fetchProfile().then((profile) => {
                            author = profile?.displayName;
                            imageUrl = profile?.image;
                            switch (inputEvent.kind) {
                                case 1: title = 'Tweet from ' + author; break;
                                case 30023: title ??= "Article by " + author; break;
                                default:
                                    title= `🎙️ ${author} - ${inputEvent.kind}`
                            }
                        });
                        
                        date = new Date(inputEvent.created_at!*1000).toLocaleDateString();

                        switch (inputEvent.kind) {
                            case 1: title = inputEvent.content.slice(0, 22); description = inputEvent.encode(); break;
                            case 30023: title = event.tagValue("title"); break;
                            default:
                                title= `🎙️ ${inputEvent.kind}`
                        }
                        description = inputEvent.content.slice(0, 100) + '...';

                        resolve();
                    });
                })
            ])

            title ??= '🎙️ ' + event.kind;
            description ??= event.content.slice(0, 100) + '...';

            console.log({title, description})

            feed.addItem({
                title,
                description,
                url,
                imageUrl,
                categories: ['Category 1','Category 2','Category 3','Category 4'], // optional - array of item categories
                author,
                date,
                enclosure: {
                    url,
                    size: 10000, //parseInt(req.headers.get('Content-Length') || "1000"),
                },
                itunesAuthor: 'Max Nowack',
                itunesExplicit: false,
                itunesSubtitle: 'I am a sub title',
                itunesSummary: description,
                itunesDuration: 12345,
            });

            resolve();
        }));
    }

    await Promise.all(promises);

    const headers = {
        'Cache-Control': `max-age=0, s-max-age=${600}`,
        'Content-Type': 'application/xml',
    };

    const body = feed.buildXml();

    return text(body, { headers });
}