import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="navbar"
export default class extends Controller {
  static targets = ["navbar", "trigger"];

  initialize() {
    this.observer = new IntersectionObserver(
      ([entry]) => {
        if (entry.isIntersecting) {
          this.navbarTarget.classList.add("-translate-y-[500px]");
          requestAnimationFrame(() => {
            setTimeout(() => {
              this.navbarTarget.classList.remove("fixed");
              this.navbarTarget.classList.add("absolute");
            }, 200);
          });
        } else {
          this.navbarTarget.classList.remove(
            "-translate-y-[500px]",
            "absolute",
          );
          this.navbarTarget.classList.add("fixed");
        }
      },
      { threshold: 0, rootMargin: "-100px 0px 0px 0px" },
    );
  }

  connect() {
    this.observer.observe(this.triggerTarget);
  }

  disconnect() {
    this.observer.disconnect();
  }
}
