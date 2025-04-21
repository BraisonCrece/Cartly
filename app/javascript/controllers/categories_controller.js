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
    const targets = [this.dailySelectorTarget, this.menuSelectorTarget];
    const classes = [
      "bg-brand-red",
      "text-red-50",
      "font-semibold",
      "text-gray-700",
      "dark:text-gray-200",
    ];

    targets.forEach((target) => {
      classes.forEach((className) => {
        target.classList.toggle(className);
      });
    });
  }
}
