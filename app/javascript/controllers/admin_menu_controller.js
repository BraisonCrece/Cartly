import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="admin-menu"
export default class extends Controller {
  static targets = ["items"];
  toggle() {
    this.itemsTarget.classList.toggle("translate-x-full");
  }
}
