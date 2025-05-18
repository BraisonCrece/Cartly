import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="scroll"
export default class extends Controller {
  static targets = ["navbar", "categoryHeader"];

  initialize() {
    this.observer = new IntersectionObserver(
      (entries, _observer) => {
        entries.forEach((entry) => {
          if (entry.isIntersecting) {
            const center = Array.from(this.navbarTarget.children).find(
              (navbarLink) => {
                return (
                  navbarLink.getAttribute("href") ===
                  `#${entry.target.children[0].id}`
                );
              },
            );
            this.centerElement(center);
          }
        });
      },
      { root: null, rootMargin: "0px", threshold: 1.0 },
    );
  }

  connect() {
    this.categoryHeaderTargets.forEach((target) => {
      this.observer.observe(target.parentElement);
    });
  }

  scrollToCategory(event) {
    event.preventDefault();
    const targetId = event.currentTarget.getAttribute("href");
    const targetElement = document.querySelector(targetId);

    this.scrollToTarget(targetElement);
  }

  centerElement(element) {
    const navbar = this.navbarTarget;
    const elementOffset = element.offsetLeft;
    const elementWidth = element.offsetWidth;
    const navbarWidth = navbar.offsetWidth;

    const scrollLeft = elementOffset - navbarWidth / 3 + elementWidth / 3;

    navbar.scrollTo({
      left: scrollLeft,
      behavior: "smooth",
    });
  }

  scrollToTarget(targetElement) {
    const headerOffset = 0;
    const elementPosition = targetElement.offsetTop;
    const offsetPosition = elementPosition - headerOffset;

    window.scrollTo({
      top: offsetPosition,
      behavior: "smooth",
    });
  }

  disconnect() {
    this.observer.disconnect();
  }
}
