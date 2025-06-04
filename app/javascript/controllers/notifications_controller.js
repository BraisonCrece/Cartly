import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static values = {
    delay: { type: Number, default: 5000 },
    transitionDuration: { type: Number, default: 300 },
  };

  connect() {
    // Show notification with smooth entrance
    requestAnimationFrame(() => {
      this.element.classList.add("notification-show");
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
    
    // Hide notification
    this.element.classList.remove("notification-show");
    this.element.classList.add("notification-hide");
    
    // Remove element after transition
    this.removeTimer = setTimeout(() => {
      if (this.element && this.element.parentNode) {
        this.element.remove();
      }
    }, this.transitionDurationValue);
  }
}