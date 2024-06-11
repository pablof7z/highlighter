import { phosphorSvelteOptimize } from "phosphor-svelte/preprocessor"
import preprocess from 'svelte-preprocess';
import adapterNode from '@sveltejs/adapter-node';
import adapterStatic from '@sveltejs/adapter-static';
import { vitePreprocess } from '@sveltejs/vite-plugin-svelte';

const mobile = !!process.env.VITE_MOBILE;

const adapter = !mobile ? adapterNode() : adapterStatic({
	pages: 'build',
	assets: 'build',
	fallback: "404.html",
	precompress: false,
});

/** @type {import('@sveltejs/kit').Config} */
const config = {
	// Consult https://github.com/sveltejs/svelte-preprocess
	// for more information about preprocessors
	compilerOptions: {
		customElement: true,
	},
	preprocess: [
		vitePreprocess(),
		phosphorSvelteOptimize(),
		preprocess({
			postcss: true
		}),
	],

	kit: {
		adapter,
		serviceWorker: {
			register: false,
		},
		prerender: {
			handleHttpError: "warn",
		},
		alias: {
			$actions: 'src/lib/actions',
			$components: 'src/lib/components',
			$icons: 'src/lib/icons',
			$modals: 'src/lib/modals',
			$stores: 'src/lib/stores',
			$utils: 'src/lib/utils',
			$views: 'src/lib/views',
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
