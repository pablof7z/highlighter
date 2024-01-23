import {
	defineConfig,
	createAppleSplashScreens,
	minimal2023Preset as preset
} from '@vite-pwa/assets-generator/config';

export default defineConfig({
	headLinkOptions: {
		preset: '2023'
	},
	preset: {
		...preset,
		appleSplashScreens: createAppleSplashScreens({
			padding: 0.3,
			resizeOptions: { background: 'black', fit: 'contain' },
			linkMediaOptions: {
				log: true,
				addMediaScreen: true,
				basePath: '/',
				xhtml: true
			},
			name: (landscape, size, dark) => {
				return `apple-splash-${landscape ? 'landscape' : 'portrait'}-${
					typeof dark === 'boolean' ? (dark ? 'dark-' : 'light-') : ''
				}${size.width}x${size.height}.png`;
			}
		})
	},
	images: ['./static/favicon.svg']
});
