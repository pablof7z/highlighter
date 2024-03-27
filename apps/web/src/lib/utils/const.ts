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
];
export const creatorRelayPubkey = import.meta.env.VITE_CREATOR_RELAY_PUBKEY;
export const defaultVerifierPubkey = creatorRelayPubkey;
export const defaultRelays = [import.meta.env.VITE_RELAY];

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