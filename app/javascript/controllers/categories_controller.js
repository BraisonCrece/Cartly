import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = [
    "selector",
    "categoryType",
    "dailySelector",
    "menuSelector",
    "drinksSelector",
  ];

  switch(e) {
    const value = e.target.dataset.value;
    this.categoryTypeTarget.value = value;
    this.setActiveSelector(value);
  }

  setActiveSelector(value) {
    if (!this.hasAllTargets()) return;
    
    const selectors = {
      menu: this.menuSelectorTarget,
      daily: this.dailySelectorTarget,
      drinks: this.drinksSelectorTarget,
    };

    Object.entries(selectors).forEach(([key, target]) => {
      if (key === value) {
        target.className = "flex-1 sm:flex-none px-4 py-2 text-sm font-medium rounded-md transition-colors bg-sky-600 text-white";
      } else {
        target.className = "flex-1 sm:flex-none px-4 py-2 text-sm font-medium rounded-md transition-colors text-gray-700 dark:text-gray-300 hover:text-gray-900 dark:hover:text-gray-100";
      }
    });
  }

  hasAllTargets() {
    return this.hasSelectorTarget && 
           this.hasCategoryTypeTarget && 
           this.hasMenuSelectorTarget && 
           this.hasDailySelectorTarget && 
           this.hasDrinksSelectorTarget;
  }
}