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
        "pulse-subtle": "pulse-subtle 6.5s infinite",
        "fade-in": "fade-in 0.25s cubic-bezier(0.16, 1, 0.3, 1)",
        "fade-in-up": "fade-in-up 0.25s cubic-bezier(0.16, 1, 0.3, 1)",
        "fade-in-scale": "fade-in-scale 0.25s cubic-bezier(0.16, 1, 0.3, 1)",
        "slide-in-right": "slide-in-right 0.25s cubic-bezier(0.16, 1, 0.3, 1)",
        "slide-in-down": "slide-in-down 0.25s cubic-bezier(0.16, 1, 0.3, 1)"
      },
      keyframes: {
        "fade-in": {
          "0%": { opacity: "0" },
          "100%": { opacity: "1" }
        },
        "fade-in-up": {
          "0%": { opacity: "0", transform: "translateY(8px)" },
          "100%": { opacity: "1", transform: "translateY(0)" }
        },
        "fade-in-scale": {
          "0%": { opacity: "0", transform: "scale(0.96)" },
          "100%": { opacity: "1", transform: "scale(1)" }
        },
        "slide-in-right": {
          "0%": { opacity: "0", transform: "translateX(12px)" },
          "100%": { opacity: "1", transform: "translateX(0)" }
        },
        "slide-in-down": {
          "0%": { opacity: "0", transform: "translateY(-8px)" },
          "100%": { opacity: "1", transform: "translateY(0)" }
        }
      },
      colors: {
        "brand-red": "#ff5757",
        "brand-comp": "#00a8a8",
        "brand-comp-dark": "#007474",
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
