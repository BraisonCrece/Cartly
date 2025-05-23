import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="search"
export default class extends Controller {
  static targets = ["form", "input"];
  
  initialize() {
    this.timeout = null;
  }

  connect() {
    this.inputTarget.addEventListener("input", (event) => {
      const query = event.target.value;
      this.debounceSearch();
    });
  }

  debounceSearch() {
    clearTimeout(this.timeout);
    this.timeout = setTimeout(() => {
      this.search();
    }, 300);
  }

  search() {
    this.formTarget.requestSubmit();
  }
}
