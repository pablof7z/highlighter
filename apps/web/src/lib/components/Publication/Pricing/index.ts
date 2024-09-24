import { NDKSubscriptionAmount } from "@nostr-dev-kit/ndk";
import Option from "./Option.svelte";

export const presets: NDKSubscriptionAmount[][] = [
    [
        { amount: 200, currency: "USD", term: "monthly" },
        { amount: 2000, currency: "USD", term: "yearly" },
        { amount: 4000, currency: "sats", term: "monthly" }
    ], [
        { amount: 500, currency: "USD", term: "monthly" },
        { amount: 3000, currency: "USD", term: "yearly" },
        { amount: 5000, currency: "sats", term: "monthly" }
    ], [
        { amount: 1000, currency: "USD", term: "monthly" },
        { amount: 10000, currency: "USD", term: "yearly" },
        { amount: 10000, currency: "sats", term: "monthly" }
    ], [
        { amount: 2500, currency: "USD", term: "monthly" },
        { amount: 25000, currency: "USD", term: "yearly" },
        { amount: 50000, currency: "sats", term: "monthly" }
    ]
];

export {
    Option
}