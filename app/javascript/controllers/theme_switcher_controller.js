import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="theme-switcher"
export default class extends Controller {
  static targets = ["darkButton", "lightButton", "root"];

  connect() {
    this.updateThemeFromLocalStorage();

    document.addEventListener("turbo:load", () => {
      this.updateThemeFromLocalStorage();
    });
  }

  toggle() {
    document.documentElement.classList.toggle("dark");

    if (document.documentElement.classList.contains("dark")) {
      localStorage.setItem("theme", "dark");
      this.showLightButton();
    } else {
      localStorage.setItem("theme", "light");
      this.showDarkButton();
    }
  }

  updateThemeFromLocalStorage() {
    const theme = localStorage.getItem("theme");

    if (theme === "dark") {
      document.documentElement.classList.add("dark");
      this.showLightButton();
    } else {
      document.documentElement.classList.remove("dark");
      this.showDarkButton();
    }
  }

  showLightButton() {
    if (this.hasDarkButtonTarget) this.darkButtonTarget.classList.add("hidden");
    if (this.hasLightButtonTarget)
      this.lightButtonTarget.classList.remove("hidden");
  }

  showDarkButton() {
    if (this.hasDarkButtonTarget)
      this.darkButtonTarget.classList.remove("hidden");
    if (this.hasLightButtonTarget)
      this.lightButtonTarget.classList.add("hidden");
  }
}
