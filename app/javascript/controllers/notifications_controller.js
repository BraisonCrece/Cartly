import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static values = {
    delay: { type: Number, default: 5000 },
    transitionDuration: { type: Number, default: 500 },
  };

  connect() {
    requestAnimationFrame(() => {
      this.element.classList.remove("opacity-0", "-translate-y-2");
    });

    this.startAutoHideTimer();
  }

  disconnect() {
    this.clearAutoHideTimer();
  }

  startAutoHideTimer() {
    this.clearAutoHideTimer();
    this.hideTimer = setTimeout(() => {
      this.close();
    }, this.delayValue);
  }

  clearAutoHideTimer() {
    if (this.hideTimer) {
      clearTimeout(this.hideTimer);
      this.hideTimer = null;
    }
    if (this.removeTimer) {
      clearTimeout(this.removeTimer);
      this.removeTimer = null;
    }
  }

  close() {
    this.clearAutoHideTimer();

    this.element.classList.add("opacity-0");
    this.removeTimer = setTimeout(() => {
      if (this.element && this.element.parentNode) {
        this.element.remove();
      }
    }, this.transitionDurationValue);
  }
}
