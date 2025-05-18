import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["handle", "menu", "icon"];

  connect() {
    this.startX = 0;
    this.currentX = 0;
    this.isDragging = false;
    this.menuWidth = 0;
    this.handleOffset = 0;

    this.handleTarget.addEventListener(
      "touchstart",
      this.touchStart.bind(this),
      { passive: true },
    );
    this.handleTarget.addEventListener("touchmove", this.touchMove.bind(this), {
      passive: false,
    });
    this.handleTarget.addEventListener("touchend", this.touchEnd.bind(this), {
      passive: true,
    });

    // Cerrar menú al hacer clic fuera
    document.addEventListener("click", this.handleDocumentClick.bind(this));
  }

  disconnect() {
    document.removeEventListener("click", this.handleDocumentClick.bind(this));
  }

  handleDocumentClick(event) {
    if (
      !this.menuTarget.contains(event.target) &&
      !this.handleTarget.contains(event.target)
    ) {
      this.closeMenu();
    }
  }

  touchStart(event) {
    this.isDragging = true;
    this.startX = event.touches[0].clientX;
    this.menuWidth = this.menuTarget.offsetWidth;

    // Desactivar transiciones durante el arrastre
    this.handleTarget.style.transition = "none";
    this.menuTarget.style.transition = "none";
  }

  touchMove(event) {
    if (!this.isDragging) return;

    event.preventDefault();
    this.currentX = event.touches[0].clientX;
    const diffX = this.startX - this.currentX;

    if (diffX <= 0) return; // Solo permitir arrastre hacia la izquierda

    // Calcular cuánto se ha movido como porcentaje de la anchura del menú
    const percentMoved = Math.min(diffX / this.menuWidth, 1);
    const menuTranslate = -percentMoved * 100;

    // Mover el menú y el manipulador juntos
    this.menuTarget.style.transform = `translateX(${101 + menuTranslate}%)`;
    this.handleTarget.style.transform = `translateY(-50%) translateX(${menuTranslate * (this.menuWidth / 100)}px)`;
  }

  touchEnd() {
    if (!this.isDragging) return;

    this.isDragging = false;

    // Reactivar transiciones
    this.handleTarget.style.transition = "transform 0.3s ease-out";
    this.menuTarget.style.transition = "transform 0.3s ease-out";

    // Si se arrastró más del 40%, abrir completamente
    const diffX = this.startX - this.currentX;
    if (diffX > this.menuWidth * 0.4) {
      this.openMenu();
    } else {
      this.closeMenu();
    }
  }

  openMenu() {
    this.menuTarget.style.transform = "translateX(2px)";
    this.handleTarget.style.transform = `translateY(-50%) translateX(-${this.menuWidth}px)`;
    this.iconTarget.style.transform = "rotate(180deg)";
  }

  closeMenu() {
    this.menuTarget.style.transform = "translateX(100%)";
    this.handleTarget.style.transform = "translateY(-50%) translateX(0)";
    this.iconTarget.style.transform = "rotate(0deg)";
  }
}
