import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["filterSection"];

  connect() {
    this.isOpen = false;
  }

  toggle() {
    if (this.isOpen) {
      this.close();
    } else {
      this.open();
    }
  }

  open() {
    const section = this.filterSectionTarget;
    section.classList.remove("max-h-0", "opacity-0");
    section.classList.add("max-h-96", "opacity-100");
    this.isOpen = true;
  }

  close() {
    const section = this.filterSectionTarget;
    section.classList.remove("max-h-96", "opacity-100");
    section.classList.add("max-h-0", "opacity-0");
    this.isOpen = false;
  }
}
