import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["content", "button", "icon"];
  
  connect() {
    this.isOpen = false;
    this.close();
  }
  
  toggle() {
    if (this.isOpen) {
      this.close();
    } else {
      this.open();
    }
  }
  
  open() {
    const contentHeight = this.contentTarget.scrollHeight;
    
    this.contentTarget.style.maxHeight = `${contentHeight}px`;
    this.contentTarget.classList.remove("opacity-0");
    this.contentTarget.classList.add("opacity-100");
    
    this.iconTarget.style.transform = "rotate(180deg)";
    
    this.animationTimeout = setTimeout(() => {
      this.contentTarget.style.maxHeight = "none";
    }, 300);
    
    this.isOpen = true;
  }
  
  close() {
    if (this.animationTimeout) {
      clearTimeout(this.animationTimeout);
    }
    
    const contentHeight = this.contentTarget.scrollHeight;
    this.contentTarget.style.maxHeight = `${contentHeight}px`;
    
    this.contentTarget.offsetHeight;
    
    requestAnimationFrame(() => {
      this.contentTarget.style.maxHeight = "0px";
      this.contentTarget.classList.remove("opacity-100");
      this.contentTarget.classList.add("opacity-0");
    });
    
    this.iconTarget.style.transform = "rotate(0deg)";
    
    this.isOpen = false;
  }
  
  disconnect() {
    if (this.animationTimeout) {
      clearTimeout(this.animationTimeout);
    }
  }
}