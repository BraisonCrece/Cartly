import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["image", "skeleton"]

  connect() {
    const isDarkMode = document.documentElement.classList.contains("dark")
    this.skeletonTargets.forEach(skeleton => {
      if (isDarkMode) {
        skeleton.classList.remove("skeleton")
      } else {
        skeleton.classList.remove("skeleton-dark")
      }
    })

    this.loadImages().then(() => {
      this.removeSkeletonClasses()
    })
  }

  async loadImages() {
    const imagePromises = this.imageTargets.map(image => {
      return image.complete ? Promise.resolve() : this.waitForLoad(image)
    })

    await Promise.all(imagePromises)
  }

  waitForLoad(image) {
    return new Promise(resolve => {
      image.addEventListener("load", resolve, { once: true })
    })
  }

  removeSkeletonClasses() {
    this.skeletonTargets.forEach(skeleton =>
      skeleton.classList.remove("skeleton", "skeleton-dark")
    )
  }

  close(event) {
    if (event.target === this.element) {
      this.element.style.animation = "fadeOut 0.2s cubic-bezier(0.16, 1, 0.3, 1) forwards"
      setTimeout(() => {
        this.element.remove()
      }, 200)
    }
  }
}
