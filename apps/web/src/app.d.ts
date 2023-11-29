// See https://kit.svelte.dev/docs/types#app
// for information about these interfaces

export type Session = {
	pubkey: string,
	nwcAvailable?: boolean,
}

declare global {
	namespace App {
		// interface Error {}
		// interface Locals {}
		// interface PageData {}
		// interface Platform {}
	}
}

export {};
