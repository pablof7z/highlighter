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
		  '32': '32px'
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
	  themes: [
		{
		  lofi: {
			...require("daisyui/src/theming/themes")["[data-theme=light]"],
			"base-100": "#f2f2f2",
			"base-200": "#ffffff",
			"accent": "#817EFF",
			".card": {
			  "background": "white",
			  "box-shadow": "0 0 0 1px rgba(0, 0, 0, 0.05), 0 1px 3px rgba(0, 0, 0, 0.1)"
			},
			".svg-logo": {
			  "fill": "black",
			},
			".text-base-100-content": {
			  "color": "#000000",
			},
			".input": {
			  "background": "white",
			},
			"mark": {
			  "background": "rgba(255, 104, 94, 0.33)",
			  "color": "#000000",
			},
			".menu": {
			  "background": "white",
			},
			".menu .menu-title": {
			  "color": "#b3b3b3",
			  "font-weight": "600",
			},
			".dropdown-content": {
			  "box-shadow": "rgba(0, 0, 0, 0) 0px 0px 0px 0px, rgba(0, 0, 0, 0) 0px 0px 0px 0px, rgba(0, 0, 0, 0.1) 0px 10px 15px -3px, rgba(0, 0, 0, 0.1) 0px 4px 6px -4px"
			},
			".grad-orange": {
			  "background-image": "radial-gradient(farthest-corner at 100% 0px, #FF7E34 0%, #FF5E63 100%)"
			},
			".grad-blue": {
			  "background-image": "radial-gradient(farthest-corner at 100% 0px, #5CA2FF 0%, #916EFF 100%)"
			},
			".btn-close-outter": {
			  "background-color": "#ffffff",
			},
			".btn-close-inner": {
			  "background-color": "#f2f2f2",
			  "color": "#232323"
			}
		  }
		},
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
			"::selection": {
			  "background": "rgba(255, 104, 94, 0.33)",
			  "color": "#FDC1BE",
			},
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
