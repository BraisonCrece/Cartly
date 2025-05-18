import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="scroll"
export default class extends Controller {
  static targets = ["navbar", "categoryHeader"];

  initialize() {
    this.visibleCategories = {};
    this.lastScrolled = 0;
    this.scrollDebounceTime = 100; // ms

    this.observer = new IntersectionObserver(
      (entries, _observer) => {
        let needsUpdate = false;

        entries.forEach((entry) => {
          if (!entry.target.children[0]) return;

          const categoryId = entry.target.children[0].id;
          const navbarLink = Array.from(this.navbarTarget?.children || []).find(
            (link) => link.getAttribute("href") === `#${categoryId}`,
          );

          if (!navbarLink) return;

          if (entry.isIntersecting) {
            this.visibleCategories[categoryId] = {
              element: navbarLink,
              position: entry.boundingClientRect.top,
              id: categoryId,
              ratio: entry.intersectionRatio,
            };
            needsUpdate = true;
          } else if (this.visibleCategories[categoryId]) {
            delete this.visibleCategories[categoryId];
            needsUpdate = true;
          }
        });

        if (needsUpdate) {
          this.updateNavbarScroll();
        }
      },
      {
        root: null,
        rootMargin: "-5% 0px",
        threshold: [0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7],
      },
    );

    // Add scroll event listener to update visible categories on scroll
    window.addEventListener("scroll", this.handleScroll.bind(this), {
      passive: true,
    });
  }

  connect() {
    // Clear any existing visible categories
    this.visibleCategories = {};

    if (this.hasCategoryHeaderTarget) {
      this.categoryHeaderTargets.forEach((target) => {
        if (target.parentElement) {
          this.observer.observe(target.parentElement);
        }
      });
    }
  }

  handleScroll() {
    const now = Date.now();
    if (now - this.lastScrolled < this.scrollDebounceTime) return;
    this.lastScrolled = now;

    // Update positions of visible categories
    Object.values(this.visibleCategories).forEach((category) => {
      const element = document.getElementById(category.id);
      if (element) {
        category.position = element.getBoundingClientRect().top;
      }
    });

    this.updateNavbarScroll();
  }

  scrollToCategory(event) {
    event.preventDefault();
    const targetId = event.currentTarget.getAttribute("href");
    const targetElement = document.querySelector(targetId);

    this.scrollToTarget(targetElement);
  }

  centerElement(element) {
    if (!element || !this.hasNavbarTarget) return;

    const navbar = this.navbarTarget;
    const elementOffset = element.offsetLeft;
    const elementWidth = element.offsetWidth;
    const navbarWidth = navbar.offsetWidth;

    // Center the element in the navbar
    const scrollLeft = elementOffset - navbarWidth / 2 + elementWidth / 2;

    // Check if we need to scroll at all (if element is already fully visible)
    const navbarScrollLeft = navbar.scrollLeft;
    const navbarScrollRight = navbarScrollLeft + navbarWidth;
    const elementLeft = elementOffset;
    const elementRight = elementOffset + elementWidth;

    // Only scroll if element isn't fully visible
    if (elementLeft < navbarScrollLeft || elementRight > navbarScrollRight) {
      navbar.scrollTo({
        left: Math.max(0, scrollLeft),
        behavior: "smooth",
      });
    }
  }

  updateNavbarScroll() {
    const categories = Object.values(this.visibleCategories);
    if (categories.length === 0 || !this.hasNavbarTarget) return;

    // Sort visible categories by their position from top to bottom
    const sortedCategories = categories.sort((a, b) => {
      return a.position - b.position;
    });

    // Find the most visible category (closest to the top of the viewport but visible)
    let topCategory = sortedCategories[0];

    // If we have multiple visible categories, prioritize the one with highest visibility ratio
    if (sortedCategories.length > 1) {
      const highVisibilityCategories = sortedCategories.filter(
        (c) => c.position > 0 && c.position < window.innerHeight / 3,
      );

      if (highVisibilityCategories.length > 0) {
        // Among the highly visible categories, choose the one with highest intersection ratio
        topCategory = highVisibilityCategories.reduce(
          (prev, current) => (current.ratio > prev.ratio ? current : prev),
          highVisibilityCategories[0],
        );
      }
    }

    this.centerElement(topCategory.element);
  }

  scrollToTarget(targetElement) {
    const headerOffset = 12;
    const elementPosition = targetElement.offsetTop;
    const offsetPosition = elementPosition - headerOffset;

    window.scrollTo({
      top: offsetPosition,
      behavior: "smooth",
    });
  }

  disconnect() {
    this.observer.disconnect();
    window.removeEventListener("scroll", this.handleScroll.bind(this));
    this.visibleCategories = {};
  }
}
