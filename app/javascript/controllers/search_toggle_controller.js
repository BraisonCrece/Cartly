import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="search-toggle"
export default class extends Controller {
  static targets = ["searchSection"];
  
  connect() {
    this.isOpen = false;
    
    // Bind handleClickOutside to this instance
    this.handleClickOutsidebound = this.handleClickOutside.bind(this);
    
    // Close search when clicking outside
    document.addEventListener('click', this.handleClickOutsidebound);
  }
  
  toggle(event) {
    // Prevent event from propagating
    if (event) event.stopPropagation();
    
    if (this.isOpen) {
      this.close();
    } else {
      this.open();
    }
  }
  
  handleClickOutside(event) {
    // Don't close if clicking inside the search section or on the toggle button
    if (this.isOpen && 
        !this.searchSectionTarget.contains(event.target) && 
        !event.target.closest('[data-action*="search-toggle#toggle"]')) {
      this.close();
    }
  }

  open() {
    // Get the height of the content to animate to
    const sectionHeight = this.searchSectionTarget.scrollHeight;
    
    // Set max-height directly for animation
    this.searchSectionTarget.style.maxHeight = `${sectionHeight}px`;
    this.searchSectionTarget.classList.remove("opacity-0");
    this.searchSectionTarget.classList.add("opacity-100");
    
    // After animation completes, set max-height to a large value to handle content changes
    this.animationTimeout = setTimeout(() => {
      this.searchSectionTarget.style.maxHeight = "500px";
    }, 300);
    
    this.isOpen = true;
  }

  close() {
    // Clear any pending timeout
    if (this.animationTimeout) {
      clearTimeout(this.animationTimeout);
    }
    
    // First set max-height to current height to prepare for animation
    const sectionHeight = this.searchSectionTarget.scrollHeight;
    this.searchSectionTarget.style.maxHeight = `${sectionHeight}px`;
    
    // Force reflow to ensure the browser picks up the change
    this.searchSectionTarget.offsetHeight;
    
    // Animate closing
    requestAnimationFrame(() => {
      this.searchSectionTarget.style.maxHeight = "0px";
      this.searchSectionTarget.classList.remove("opacity-100");
      this.searchSectionTarget.classList.add("opacity-0");
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
