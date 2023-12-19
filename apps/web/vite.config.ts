import { sentrySvelteKit } from "@sentry/sveltekit";
import { sveltekit } from '@sveltejs/kit/vite';
import { defineConfig } from 'vite';
import { nodePolyfills } from 'vite-plugin-node-polyfills';
import { SvelteKitPWA } from "@vite-pwa/sveltekit";
import mkcert from'vite-plugin-mkcert'

export default defineConfig({
    server: {
        https: true
    },
	plugins: [
        sentrySvelteKit({
            sourceMapsUploadOptions: {
                org: "pablof7z",
                project: "fans",
                telemetry: false,
            },
        }),
        sveltekit(),
        SvelteKitPWA({
            strategies: "generateSW",
            manifest: {
                short_name: "Faaans",
                name: "Faaans",
                theme_color: "#000000",
                icons: [
                    {
                        src: '/pwa-192x192.png',
                        sizes: '192x192',
                        type: 'image/png',
                    },
                    {
                        src: '/pwa-512x512.png',
                        sizes: '512x512',
                        type: 'image/png',
                    },
                    {
                        src: '/pwa-512x512.png',
                        sizes: '512x512',
                        type: 'image/png',
                        purpose: 'any maskable',
                    },
                ],
            }
        }),
        nodePolyfills(),
        mkcert()
    ],
});