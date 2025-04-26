import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["image", "loader"];

  connect() {
    if (this.hasImageTarget && this.imageTarget.complete) {
      this.imageLoaded();
    }
  }

  imageLoaded() {
    if (this.hasLoaderTarget) {
      this.loaderTarget.classList.add("hidden");
    }
    if (this.hasImageTarget) {
      this.imageTarget.classList.remove("opacity-0");
    }
  }
}
