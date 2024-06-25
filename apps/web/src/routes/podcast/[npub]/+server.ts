import { ndk } from '$stores/ndk.js';
import { text } from '@sveltejs/kit';
import { Podcast } from 'podcast';
import { get } from 'svelte/store';

export async function GET({ url, params }) {
    const $ndk = get(ndk);
    const { npub } = params;

    const user = $ndk.getUser({npub});
    const profile = await user.fetchProfile();
    console.log('profile', profile);

    const feed = new Podcast({
        title: "Highlighter for " + profile.displayName,
    });

    // use HEAD to get the length of the file in https://pblsw.ngrok.io/podcast/npub1l2vyh47mk2p0qlsku7hg0vn29faehy9hy34ygaclpn66ukqp3afqutajft
    // const req = await fetch('https://pblsw.ngrok.io/podcast/npub1l2vyh47mk2p0qlsku7hg0vn29faehy9hy34ygaclpn66ukqp3afqutajft', {
    //     method: 'HEAD',
    // });

    feed.addItem({
        title:  'item title',
        description: 'use this for the content. It can include html.',
        url: 'https://privatevideotranslation.s3.us-west-1.amazonaws.com/Swann73a8263853d65211cd6d2eeb88a8a0cd9650305bda4f0b4c9eea0907d24a2e98.wav', // link to the item
        categories: ['Category 1','Category 2','Category 3','Category 4'], // optional - array of item categories
        author: 'Guest Author', // optional - defaults to feed author property
        date: 'May 27, 2012', // any format that js Date can parse.
        enclosure: {
            url: 'https://privatevideotranslation.s3.us-west-1.amazonaws.com/Swann73a8263853d65211cd6d2eeb88a8a0cd9650305bda4f0b4c9eea0907d24a2e98.wav',
            size: 10000, //parseInt(req.headers.get('Content-Length') || "1000"),
        },
        itunesAuthor: 'Max Nowack',
        itunesExplicit: false,
        itunesSubtitle: 'I am a sub title',
        itunesSummary: 'I am a summary',
        itunesDuration: 12345,
    });

    const headers = {
        'Cache-Control': `max-age=0, s-max-age=${600}`,
        'Content-Type': 'application/xml',
      };

    const body = feed.buildXml();

    console.log('body', body);

    return text(body, { headers });
}