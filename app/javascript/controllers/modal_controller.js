import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["image", "skeleton"];

  connect() {
    // Check if images are already loaded (cached)
    const allImagesLoaded = this.imageTargets.every(
      (image) => image.complete && image.naturalHeight !== 0,
    );

    if (allImagesLoaded) {
      // Images are cached, remove skeletons immediately
      this.removeSkeletonClasses(true);
    } else {
      // Images need to load, wait for them
      this.loadImages().then(() => {
        this.removeSkeletonClasses(false);
      });
    }
  }

  async loadImages() {
    const imagePromises = this.imageTargets.map((image) => {
      return image.complete && image.naturalHeight !== 0
        ? Promise.resolve()
        : this.waitForLoad(image);
    });

    await Promise.all(imagePromises);
  }

  waitForLoad(image) {
    return new Promise((resolve) => {
      image.addEventListener("load", resolve, { once: true });
      image.addEventListener("error", resolve, { once: true });
    });
  }

  removeSkeletonClasses(immediate = false) {
    this.skeletonTargets.forEach((skeleton) => {
      if (immediate) {
        skeleton.classList.remove("skeleton");
        skeleton.classList.add("loaded");
      } else {
        skeleton.style.transition = "opacity 0.1s ease-out";
        skeleton.style.opacity = "0";

        setTimeout(() => {
          skeleton.classList.remove("skeleton");
          skeleton.classList.add("loaded");
          skeleton.style.opacity = "1";
          skeleton.style.transition = "";
        }, 100);
      }
    });
  }

  close(event) {
    if (event.target === this.element) {
      this.element.style.animation =
        "fadeOut 0.15s cubic-bezier(0.16, 1, 0.3, 1) forwards";
      setTimeout(() => {
        this.element.remove();
      }, 150);
    }
  }
}
