const konstaConfig = require('konsta/config');


/** @type {import('tailwindcss').Config} */
export default konstaConfig({
  content: ["./src/**/*.{html,js,svelte,ts}"],

  theme: {
    extend: {},
  },

  plugins: [require("@tailwindcss/typography")],
});