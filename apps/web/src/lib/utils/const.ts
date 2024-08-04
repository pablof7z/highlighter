import type { Hexpubkey } from "@nostr-dev-kit/ndk";

export const blacklistedPubkeys = [
    "a2155842128093cac2c5120c9830d568c8556b95f6e03eeca3946bcd4309b43b", // marinalunes@nostr.me
    "0a6dfac7f5df57c3f21bdd265925dd09db51ad9324e41b63d521636574ba26da", // abcdef123@lume.nu
    "078b47b4b15a27ace85ea157175d8999579cbc040fcb73f863ffbddb7f0a751f", // blake@highlighter.com
    "6fc5ee366dd11d9b4a597a24c7c9e18d0deac078213b60ddb158d82a046f1d3c",
    "eaa49a30e4e74e1436c7271bc33c6d7bdf0db2435739a70460771e98e969ca49", // henry@nostr.me
    "4f7bd9c066a7b21d750b4e8dbf4440ef1e80c64864341550200b8481d530c5ce", // getfaaans
    "a8a5726e06cd5c462211e1ca863fd498cacf242a1ecfc8fe89efa2a685896952", // ppp@getfaaans.com
    "67fc313ff8a5445c5ec77e4287348356c9cb123df8d045485f171a76e71dc703",
    "06e3591d054a5e50433fc5c9cd99f7d2acda8cc610e046ba502992639fe735b6", // jhhhh@nostr.me
    "c73818cc95d6adf098fbff289cda4c3cf50d5f370d25f0b6f3677231ccd5c890", // spam
    "82fbb08c8ef45c4d71c88368d0ae805bc62fb92f166ab04a0b7a0c83d8cbc29a" // notary@pablof7z.com
];
export const creatorRelayPubkey = import.meta.env.VITE_CREATOR_RELAY_PUBKEY;
export const defaultVerifierPubkey = creatorRelayPubkey;
export const defaultRelays = [import.meta.env.VITE_RELAY];

export const blacklistedTags = new Set([
    "bitcoin",
]);

export const vanityUrls: Record<string, Hexpubkey> = {
	"avichand": "5002cb487a6e03a781d20b4d115bfc0e96abf7802d9ba4ee49d75a0231a0d6d8",
	"max": "fe7f6bc6f7338b76bbf80db402ade65953e20b2f23e66e898204b63cc42539a3",
	"maxdemarco": "fe7f6bc6f7338b76bbf80db402ade65953e20b2f23e66e898204b63cc42539a3",
    "pablof7z": "fa984bd7dbb282f07e16e7ae87b26a2a7b9b90b7246a44771f0cf5ae58018f52",
	"svetski": "6ad08392d1baa3f6ff7a9409e2ac5e5443587265d8b4a581c6067d88ea301584",
    "miljan": "d61f3bc5b3eb4400efdae6169a5c17cabf3246b514361de939ce4a1a0da6ef4a",
    "ODELL": "04c915daefee38317fa734444acee390a8269fe5810b2241e5e6dd343dfbecc9",
    "walker": "c48e29f04b482cc01ca1f9ef8c86ef8318c059e0e9353235162f080f26e14c11",
    "chrisliss": "6ad3e2a34818b153c81f48c58f44e5199e7b4fc8dbe37810a000dce3c90b7740",
    "onigirl": "3c9849383bdea883b0bd16fece1ed36d37e37cdde3ce43b17ea4e9192ec11289",
    "bitcoinand": "6389be6491e7b693e9f368ece88fcd145f07c068d2c1bbae4247b9b5ef439d32",
    "verbiricha": "7fa56f5d6962ab1e3cd424e758c3002b8665f7b0d8dcee9fe9e288d7751ac194",
    "dergigi": "6e468422dfb74a5738702a8823b9b28168abab8655faacb6853cd0ee15deee93",
    "karnage": "1bc70a0148b3f316da33fe3c89f23e3e71ac4ff998027ec712b905cd24f6a411",
    "hodlbod": "97c70a44366a6535c145b333f973ea86dfdc2d7a99da618c40c64705ad98e322",
    "laeserin": "dd664d5e4016433a8cd69f005ae1480804351789b59de5af06276de65633d319",
    "hzrd149": "266815e0c9210dfa324c6cba3573b14bee49da4209a9456f9484e5106cd408a5",
    "yael": "a367f9eb1cb3a241a7f3646f31cd6d597bbbbf8eaeb5cd2e707d09b00633efea",
    "daniel": "a09fb9cb21861a5bda2475b0ce703d0f96b783f9d552fe3184407f1d83231556",
}

export const vanityUrlsByPubkey: Record<Hexpubkey, string> = Object.fromEntries(
    Object.entries(vanityUrls).map(([k, v]) => [v, k])
);

export const featuredCreatorPubkeys = [
    vanityUrls.maxdemarco,
    vanityUrls.chrisliss,
    vanityUrls.walker,
]

if (!creatorRelayPubkey) {
    console.error("No creator relay pubkey found");
    process.exit(1);
}

if (!defaultRelays.length) {
    console.error("No default relays found");
    process.exit(1);
}

if (!defaultVerifierPubkey) {
    console.error("No default verifier pubkey found");
    process.exit(1);
}

export const featuredCreatorsPerCategory: Record<string, Hexpubkey[]> = {
    "Entrepreneurship": [
        vanityUrls.svetski,
        vanityUrls.karnage
    ],
    "Freedom Tech": [
        vanityUrls.maxdemarco,
        vanityUrls.chrisliss,
        vanityUrls.pablof7z,
        vanityUrls.karnage,
        vanityUrls.hodlbod,
        vanityUrls.hzrd149
    ],
    "UX / Design": [
        vanityUrls.karnage
    ],
    "Philosophy": [
        vanityUrls.chrisliss,
        vanityUrls.dergigi,
        vanityUrls.hodlbod
    ],
}

export const unicodeEmojiRegex = /[\p{Emoji}]/gu;