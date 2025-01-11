import { Controller } from "@hotwired/stimulus";
import Sortable from "sortablejs";

// Connects to data-controller="sortable"
export default class extends Controller {
  static targets = ["menuList", "dailyList"];

  connect() {
    Sortable.create(this.menuListTarget, {
      onEnd: function (evt) {
        const itemEl = evt.item;
        const categoryId = itemEl.dataset.id;
        const crsf = document.querySelector('meta[name="csrf-token"]').content;
        const order = Array.from(evt.to.children).map((el) => el.dataset.id);

        fetch("/sort", {
          method: "POST",
          headers: {
            "Content-Type": "application/json",
            "X-CSRF-Token": crsf,
          },
          body: JSON.stringify({
            id: categoryId,
            order: order,
          }),
        });
      },
    });

    Sortable.create(this.dailyListTarget, {
      onEnd: function (evt) {
        const itemEl = evt.item;
        const categoryId = itemEl.dataset.id;
        const crsf = document.querySelector('meta[name="csrf-token"]').content;
        const order = Array.from(evt.to.children).map((el) => el.dataset.id);

        fetch("/sort", {
          method: "POST",
          headers: {
            "Content-Type": "application/json",
            "X-CSRF-Token": crsf,
          },
          body: JSON.stringify({
            id: categoryId,
            order: order,
          }),
        });
      },
    });
  }
}
