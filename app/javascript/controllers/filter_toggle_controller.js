import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="filter-toggle"
export default class extends Controller {
  static targets = ["filterMenu"];
  
  connect() {
    this.isOpen = false;
    
    // Bind handleClickOutside to this instance
    this.handleClickOutsidebound = this.handleClickOutside.bind(this);
    
    // Close filter when clicking outside
    document.addEventListener('click', this.handleClickOutsidebound);
  }
  
  toggle(event) {
    // Prevent the event from bubbling up
    event.stopPropagation();
    
    if (this.isOpen) {
      this.close();
    } else {
      this.open();
    }
  }
  
  handleClickOutside(event) {
    // Don't close if clicking inside the filter menu or on the filter button
    if (this.isOpen && 
        !this.filterMenuTarget.contains(event.target) && 
        !event.target.closest('[data-action*="filter-toggle#toggle"]')) {
      this.close();
    }
  }
  
  open() {
    // Get the height of the content to animate to
    const menuHeight = this.filterMenuTarget.scrollHeight;
    
    // Set max-height directly for animation
    this.filterMenuTarget.style.maxHeight = `${menuHeight}px`;
    this.filterMenuTarget.classList.remove("opacity-0");
    this.filterMenuTarget.classList.add("opacity-100");
    
    // After animation completes, set max-height to a large value to handle content changes
    this.animationTimeout = setTimeout(() => {
      this.filterMenuTarget.style.maxHeight = "500px";
    }, 300);
    
    this.isOpen = true;
  }
  
  close() {
    // Clear any pending timeout
    if (this.animationTimeout) {
      clearTimeout(this.animationTimeout);
    }
    
    // First set max-height to current height to prepare for animation
    const menuHeight = this.filterMenuTarget.scrollHeight;
    this.filterMenuTarget.style.maxHeight = `${menuHeight}px`;
    
    // Force reflow to ensure the browser picks up the change
    this.filterMenuTarget.offsetHeight;
    
    // Animate closing
    requestAnimationFrame(() => {
      this.filterMenuTarget.style.maxHeight = "0px";
      this.filterMenuTarget.classList.remove("opacity-100");
      this.filterMenuTarget.classList.add("opacity-0");
    });
    
    this.isOpen = false;
  }
  
  disconnect() {
    // Clean up any pending timeouts when controller is disconnected
    if (this.animationTimeout) {
      clearTimeout(this.animationTimeout);
    }
    
    // Remove event listener
    document.removeEventListener('click', this.handleClickOutsidebound);
  }
}