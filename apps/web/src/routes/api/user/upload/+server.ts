// import { writeFileSync } from 'fs';
// import { NDKEvent, type NostrEvent } from '@nostr-dev-kit/ndk';
// import createDebug from "debug";
// import type { Session } from '../../../../app';
// import { ndk } from "$stores/ndk";
// import { get } from 'svelte/store';
// import { fail, json } from '@sveltejs/kit';

// const debug = createDebug("highlighter:/api/user/upload");

// export async function POST({ request }) {
//     const $ndk = get(ndk);
//     const {pubkey} = locals.session as Session;
//     const body = await request.json();
//     const { fileSize } = body;

//     debug('upload', {pubkey, fileSize});

//     const uploadEvent = new NDKEvent($ndk, {
//         created_at: Math.ceil(Date.now() / 1000),
//         kind: 22242,
//         content: 'Authorize Upload',
//     } as NostrEvent);
//     await uploadEvent.sign();

//     return json({
//         upload: {
//             event: uploadEvent,
//         }
//     });
// }

// // define PUT verb that accepts a file and saves it into the filesystem
// export async function PUT({ request, locals }) {
//     const {pubkey} = locals.session as Session;
//     const formData = Object.fromEntries(await request.formData());

//     debug('upload', {pubkey, formData});

//     if (
//         !(formData.file as File).name ||
//         (formData.file as File).name === 'undefined'
//     ) {
//         return json( {
//             error: true,
//             message: 'You must provide a file to upload'
//         }, {
//             status: 400
//         });
//     }

//     const { file } = formData as { file: File };

//     // Write the file to the static folder
//     writeFileSync(`static/${file.name}`, Buffer.from(await file.arrayBuffer()));

//     return json({
//         success: true
//     });
// }
