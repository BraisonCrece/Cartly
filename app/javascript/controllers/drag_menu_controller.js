import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["handle", "menu", "icon"];

  connect() {
    this.startX = 0;
    this.currentX = 0;
    this.isDragging = false;
    this.menuWidth = 0;
    this.handleWidth = 0;
    this.isMenuOpen = false;
    this.dragThreshold = 10;
    this.hasDragged = false;

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
    this.handleTarget.addEventListener("click", this.handleClick.bind(this));

    // Cerrar menú al hacer clic fuera
    document.addEventListener("click", this.handleDocumentClick.bind(this));
    
    // Initialize dimensions
    this.updateDimensions();
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
    this.hasDragged = false;
    this.startX = event.touches[0].clientX;
    this.updateDimensions();

    // Desactivar transiciones durante el arrastre
    this.handleTarget.style.transition = "none";
    this.menuTarget.style.transition = "none";
  }

  touchMove(event) {
    if (!this.isDragging) return;

    this.currentX = event.touches[0].clientX;
    const diffX = Math.abs(this.startX - this.currentX);

    if (diffX > this.dragThreshold) {
      this.hasDragged = true;
      event.preventDefault();
    }

    const moveX = this.startX - this.currentX;
    if (moveX <= 0) return; // Solo permitir arrastre hacia la izquierda

    // Calcular cuánto se ha movido como porcentaje de la anchura del menú
    const percentMoved = Math.min(moveX / this.menuWidth, 1);
    const menuTranslate = -percentMoved * 100;

    // Mover el menú y el manipulador juntos
    this.menuTarget.style.transform = `translateX(${100 + menuTranslate}%)`;
    const handleOffset = (percentMoved * this.menuWidth) - (this.handleWidth / 2);
    this.handleTarget.style.transform = `translateY(-50%) translateX(-${handleOffset}px)`;
  }

  touchEnd() {
    if (!this.isDragging) return;

    this.isDragging = false;

    // Reactivar transiciones
    this.handleTarget.style.transition = "transform 0.3s ease-out";
    this.menuTarget.style.transition = "transform 0.3s ease-out";

    if (this.hasDragged) {
      // Si se arrastró más del 40%, abrir completamente
      const diffX = this.startX - this.currentX;
      if (diffX > this.menuWidth * 0.4) {
        this.openMenu();
      } else {
        this.closeMenu();
      }
    }
  }

  handleClick(event) {
    if (this.hasDragged) return;
    
    event.preventDefault();
    this.toggleMenu();
  }

  toggleMenu() {
    if (this.isMenuOpen) {
      this.closeMenu();
    } else {
      this.openMenu();
    }
  }

  updateDimensions() {
    this.menuWidth = this.menuTarget.offsetWidth;
    this.handleWidth = this.handleTarget.offsetWidth;
  }

  openMenu() {
    this.isMenuOpen = true;
    this.updateDimensions();
    this.menuTarget.style.transform = "translateX(0)";
    this.handleTarget.style.transform = `translateY(-50%) translateX(-${this.menuWidth - (this.handleWidth / 2)}px)`;
    this.iconTarget.style.transform = "rotate(180deg)";
  }

  closeMenu() {
    this.isMenuOpen = false;
    this.menuTarget.style.transform = "translateX(100%)";
    this.handleTarget.style.transform = "translateY(-50%) translateX(0)";
    this.iconTarget.style.transform = "rotate(0deg)";
  }
}
