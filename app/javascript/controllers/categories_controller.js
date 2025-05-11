import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = [
    "selector",
    "categoryType",
    "dailySelector",
    "menuSelector",
    "drinksSelector",
  ];

  connect() {
    this.setActiveSelector("menu");
    this.categoryTypeTarget.value = "menu";
  }

  switch(e) {
    const value = e.target.dataset.value;
    this.categoryTypeTarget.value = value;
    this.setActiveSelector(value);
  }

  setActiveSelector(value) {
    const selectors = {
      menu: this.menuSelectorTarget,
      daily: this.dailySelectorTarget,
      drinks: this.drinksSelectorTarget,
    };
    const activeClasses = ["bg-brand-red", "text-red-50", "font-semibold"];
    const inactiveClasses = ["text-gray-600", "dark:text-gray-200"];

    Object.entries(selectors).forEach(([key, target]) => {
      if (key === value) {
        activeClasses.forEach((c) => target.classList.add(c));
        inactiveClasses.forEach((c) => target.classList.remove(c));
      } else {
        activeClasses.forEach((c) => target.classList.remove(c));
        inactiveClasses.forEach((c) => target.classList.add(c));
      }
    });
  }
}
