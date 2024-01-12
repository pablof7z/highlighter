/** @type {import('tailwindcss').Config} */
module.exports = {
	content: [
		'./src/**/*.{html,js,svelte,ts}',
		"./node_modules/flowbite-svelte/**/*.{html,js,svelte,ts}",
	],
	// darkMode: 'class',
	theme: {
	  extend: {
		sans: ['Inter var'],
		colors: {
		  "gradient1": "#FF5E63",
		  "gradient2": "#FF7E34",
		  "gradient3": "#916EFF",
		  "gradient4": "#5CA2FF",
		  "accent2": "#FB6038",
		},
		width: {
		  'sidebar': '244px',
		  'main': '700px',
		},
		spacing: {
			'mobile-nav-bar': 'var(--mobile-nav-bar, 63px)',
			'mobile-body-padding': 'var(--mobile-body-padding, 4px)',
		}
	  },
	  fontFamily: {
		serif: ["Lora"]
	  }
	},
	plugins: [
	  require('@tailwindcss/forms'),
	  require("@tailwindcss/typography"),
	  require("daisyui"),
	],
	daisyui: {
		utils: true,
		styled: true,
	  themes: [
		{
		  black: {
			...require("daisyui/src/theming/themes")["[data-theme=dark]"],
			"base-100": "#000000",
			"base-200": "#111111",
			"base-300": "#232323",
			"neutral-800": "#232323",
			"neutral-900": "#111111",
			".menu": {
			  "background": "#111111",
			},
			"h1": {
			  "color": "#ffffff",
			},
			".tab-active": {
			  "color": "#ffffff",
			},
			"accent": "#817EFF",
			".btn": {
			  "border-radius": "5px",
			  "text-transform": "none",
			},
			".btn-rounded-full": {
			  "border-radius": "9999px !important",
			},
			".btn-circle": {
			  "border-radius": "9999px !important",
			},
			".btn-close-outter": {
			  "background-color": "#000000",
			},
			".btn-close-inner": {
			  "background-color": "#232323",
			  "color": "#B3B3B3"
			},
			".card": {
			  "background": "#111111"
			},
			".card:not([class^=\"rounded\"])": {
			  "border-radius": "5px",
			},
			".input": {
			  "background": "rgb(26, 25, 25)",
			},
			".svg-logo": {
			  "fill": "white",
			},
			".text-base-100-content": {
			  "color": "#ffffff",
			},
			".dropdown-content": {
			  "box-shadow": "rgba(0, 0, 0, 0) 0px 0px 0px 0px, rgba(0, 0, 0, 0) 0px 0px 0px 0px, rgba(0, 0, 0, 0.1) 0px 1px 3px 0px, rgba(0, 0, 0, 0.1) 0px 1px 2px -1px"
			},
			"mark": {
			  "background": "rgba(255, 104, 94, 0.33)",
			  "color": "#FDC1BE",
			},
			// "::selection": {
			//   "background": "rgba(255, 104, 94, 0.33)",
			//   "color": "#FDC1BE",
			// },
			"mark.active": {
			  "background": "rgba(246, 48, 2, 0.8)",
			  "color": "#FFF0F0"
			}
		  }
		}
	  ],
	  "darkTheme": "black",
	},
  }
