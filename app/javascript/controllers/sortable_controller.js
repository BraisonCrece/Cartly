import { Controller } from "@hotwired/stimulus";
import Sortable from "sortablejs";

// Connects to data-controller="sortable"
export default class extends Controller {
  static targets = ["menuList", "dailyList", "drinksList"];

  connect() {
    this.initializeSortables();
    this.observeChanges();
  }

  disconnect() {
    if (this.observer) {
      this.observer.disconnect();
    }
  }

  menuListTargetConnected() {
    this.initializeSortable(this.menuListTarget);
  }

  dailyListTargetConnected() {
    this.initializeSortable(this.dailyListTarget);
  }

  drinksListTargetConnected() {
    this.initializeSortable(this.drinksListTarget);
  }

  menuListTargetDisconnected() {
    this.destroySortable(this.menuListTarget);
  }

  dailyListTargetDisconnected() {
    this.destroySortable(this.dailyListTarget);
  }

  drinksListTargetDisconnected() {
    this.destroySortable(this.drinksListTarget);
  }

  initializeSortables() {
    if (this.hasMenuListTarget) {
      this.initializeSortable(this.menuListTarget);
    }
    if (this.hasDailyListTarget) {
      this.initializeSortable(this.dailyListTarget);
    }
    if (this.hasDrinksListTarget) {
      this.initializeSortable(this.drinksListTarget);
    }
  }

  initializeSortable(element) {
    if (!element || element.sortable) return;

    element.sortable = Sortable.create(element, {
      handle: '[data-sortable-handle]',
      onEnd: (evt) => this.handleSort(evt)
    });
  }

  destroySortable(element) {
    if (element && element.sortable) {
      element.sortable.destroy();
      delete element.sortable;
    }
  }

  handleSort(evt) {
    const itemEl = evt.item;
    const categoryId = itemEl.dataset.id;
    const csrf = document.querySelector('meta[name="csrf-token"]').content;
    const order = Array.from(evt.to.children).map((el) => el.dataset.id);

    fetch("/sort", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": csrf,
      },
      body: JSON.stringify({
        id: categoryId,
        order: order,
      }),
    });
  }

  observeChanges() {
    this.observer = new MutationObserver(() => {
      requestAnimationFrame(() => {
        this.findAndInitializeTargets();
      });
    });

    this.observer.observe(this.element, {
      childList: true,
      subtree: true,
      attributes: true,
      attributeFilter: ['data-sortable-target']
    });
  }

  findAndInitializeTargets() {
    const menuList = this.element.querySelector('[data-sortable-target="menuList"]');
    const dailyList = this.element.querySelector('[data-sortable-target="dailyList"]');
    const drinksList = this.element.querySelector('[data-sortable-target="drinksList"]');

    if (menuList && !menuList.sortable) {
      this.initializeSortable(menuList);
    }
    if (dailyList && !dailyList.sortable) {
      this.initializeSortable(dailyList);
    }
    if (drinksList && !drinksList.sortable) {
      this.initializeSortable(drinksList);
    }
  }
}