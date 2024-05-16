import { sveltekit } from '@sveltejs/kit/vite';
import { defineConfig } from 'vite';
import { nodePolyfills } from 'vite-plugin-node-polyfills';
import { SvelteKitPWA } from '@vite-pwa/sveltekit';
import mkcert from 'vite-plugin-mkcert';

const mobileBuild = !!process.env.MOBILE;

let pwa: any[] = mobileBuild ? [] : [SvelteKitPWA({
    strategies: 'generateSW',
    srcDir: 'src',
    registerType: 'autoUpdate',
    injectRegister: "inline",
    manifest: {
        short_name: 'Highlighter',
        name: 'Highlighter',
        theme_color: '#000000',
        protocol_handlers: [
            { protocol: 'web+nostr', url: '/%s' },
        ],
        icons: [
            {
                src: '/pwa-192x192.png',
                sizes: '192x192',
                type: 'image/png'
            },
            {
                src: '/pwa-512x512.png',
                sizes: '512x512',
                type: 'image/png'
            },
            {
                src: '/pwa-512x512.png',
                sizes: '512x512',
                type: 'image/png',
                purpose: 'any'
            },
            {
                src: '/pwa-512x512.png',
                sizes: '512x512',
                type: 'image/png',
                purpose: 'maskable'
            }
        ]
    }
})]

export default defineConfig({
	server: {
		https: false
	},
	plugins: [
        sveltekit(),
        ...pwa,
        nodePolyfills(), mkcert()],
    optimizeDeps: {
		exclude: [
            "phosphor-svelte",
        ],
	},
});