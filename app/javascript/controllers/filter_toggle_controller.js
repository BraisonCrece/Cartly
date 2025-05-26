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
    const scrollHeight = section.scrollHeight;

    section.style.maxHeight = scrollHeight + "px";
    section.classList.remove("opacity-0");
    section.classList.add("opacity-100");
    this.isOpen = true;
  }

  close() {
    const section = this.filterSectionTarget;

    section.style.maxHeight = "0px";
    section.classList.remove("opacity-100");
    section.classList.add("opacity-0");
    this.isOpen = false;
  }
}
