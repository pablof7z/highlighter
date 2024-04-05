# Highlighter

## NIP-29
Highlighter relies heavily on NIP-29.

- [] When a new creator signs up (i.e. creates tiers), a NIP-29 group is created where the `h` tag matches the pubkey of the creator by publishing a kind:9006 event.
- [] When a user subscribes to a tier, a `kind:9000`
