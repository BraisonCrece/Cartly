const defaultTheme = require("tailwindcss/defaultTheme")

module.exports = {
  darkMode: "class",
  content: [
    "./public/*.html",
    "./app/helpers/**/*.rb",
    "./app/javascript/**/*.js",
    "./app/views/**/*.html.erb",
    "./app/views/**/*.erb"
  ],
  theme: {
    extend: {
      fontFamily: {
        sans: ["Inter var", ...defaultTheme.fontFamily.sans],
        play: ["PlayFair", ...defaultTheme.fontFamily.sans],
        roboto: ["Roboto", ...defaultTheme.fontFamily.sans]
      },
      fontSize: {
        xxs: "0.4rem"
      },
      animation: {
        "pulse-subtle": "pulse-subtle 6.5s infinite"
      },
      colors: {
        "brand-red": "#ff5757",
        "brand-red-dark": "#bf4143",
        "brand-red-light": "#ff7073",
        "brand-gray": "#374151",
        "brand-gray-light": "#49566b",
        "brand-gray-dark": "#262d38"
      }
    }
  },
  plugins: [
    require("@tailwindcss/forms"),
    require("@tailwindcss/aspect-ratio"),
    require("@tailwindcss/typography"),
    require("@tailwindcss/container-queries")
  ]
}
