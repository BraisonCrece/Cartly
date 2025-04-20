// app/javascript/controllers/categories_controller.js
import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = [
    "selector",
    "categoryType",
    "dailySelector",
    "menuSelector",
  ];

  connect() {
    this.categoryTypeTarget.setAttribute("value", "menu");
  }

  switch(e) {
    this.categoryTypeTarget.setAttribute("value", e.target.dataset.value);
    this.dailySelectorTarget.classList.toggle("bg-brand-red");
    this.menuSelectorTarget.classList.toggle("bg-brand-red");
  }
}
