import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="sticky-shadow"
export default class extends Controller {
  static targets = ["sticky"];

  connect() {
    const stickyElement = this.stickyTarget;

    window.addEventListener("scroll", () => {
      if (window.scrollY > 0) {
        stickyElement.classList.add("shadow-md");
      } else {
        stickyElement.classList.remove("shadow-md");
      }
    });
  }
}
