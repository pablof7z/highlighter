import preprocess from 'svelte-preprocess';
import adapter from '@sveltejs/adapter-node';
import { vitePreprocess } from '@sveltejs/kit/vite';

/** @type {import('@sveltejs/kit').Config} */
const config = {
	// Consult https://github.com/sveltejs/svelte-preprocess
	// for more information about preprocessors
	preprocess: [
		vitePreprocess(),
		preprocess({
			postcss: true
		})
	],

	kit: {
		adapter: adapter(),
		alias: {
			$actions: 'src/lib/actions',
			$components: 'src/lib/components',
			$icons: 'src/lib/icons',
			$modals: 'src/lib/modals',
			$stores: 'src/lib/stores',
			$utils: 'src/lib/utils',
			$lib: 'src/lib',
			$api: "src/lib/api",
		}
	},

	vitePlugin: {
		inspector: {
			holdMode: true,
			toggleKeyCombo: 'control-shift'
		}
	},
	onwarn: (warning, handler) => {
        if (warning.code.startsWith("a11y-")) {
            return;
        }
        handler(warning);
    },
};

export default config;
