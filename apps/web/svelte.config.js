import { phosphorSvelteOptimize } from "phosphor-svelte/preprocessor"
import preprocess from 'svelte-preprocess';
// import adapter from '@sveltejs/adapter-node';
import adapter from '@sveltejs/adapter-static';
import { vitePreprocess } from '@sveltejs/vite-plugin-svelte';

/** @type {import('@sveltejs/kit').Config} */
const config = {
	// Consult https://github.com/sveltejs/svelte-preprocess
	// for more information about preprocessors
	preprocess: [
		vitePreprocess(),
		phosphorSvelteOptimize(),
		preprocess({
			postcss: true
		})
	],

	kit: {
		// adapter: adapter(),
		adapter: adapter({ fallback : '404.html' }),
		alias: {
			$actions: 'src/lib/actions',
			$components: 'src/lib/components',
			$icons: 'src/lib/icons',
			$modals: 'src/lib/modals',
			$stores: 'src/lib/stores',
			$utils: 'src/lib/utils',
			$lib: 'src/lib',
			$api: 'src/lib/api',
			$db: 'src/db',
		}
	},

	vitePlugin: {
		inspector: {
			holdMode: true,
			toggleKeyCombo: 'control-shift'
		}
	},
	onwarn: (warning, handler) => {
		if (warning.code.startsWith('a11y-')) {
			return;
		}
		handler(warning);
	}
};

export default config;
