import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["typeSelector", "categoryWrapper", "categorySelect", "dailyButton", "menuButton", "addCategoryLink"]
  static values = { selectedType: String }

  connect() {
    // If there's a pre-selected category, determine its type and show the UI accordingly
    if (this.hasSelectedCategory()) {
      const selectedOption = this.categorySelectTarget.selectedOptions[0]
      if (selectedOption && selectedOption.dataset.categoryType) {
        this.selectedTypeValue = selectedOption.dataset.categoryType
        this.updateButtonStates()
        this.showCategoriesFor(this.selectedTypeValue)
      }
    } else {
      this.hideCategories()
    }
  }

  selectDaily(event) {
    event.preventDefault()
    this.selectedTypeValue = "daily"
    this.updateButtonStates()
    this.showCategoriesFor("daily")
  }

  selectMenu(event) {
    event.preventDefault()
    this.selectedTypeValue = "menu"
    this.updateButtonStates()
    this.showCategoriesFor("menu")
  }

  updateButtonStates() {
    // Remove active state from all buttons
    this.dailyButtonTarget.classList.remove("ring-2", "ring-sky-500", "border-sky-500", "bg-sky-50", "dark:bg-sky-900/20")
    this.menuButtonTarget.classList.remove("ring-2", "ring-sky-500", "border-sky-500", "bg-sky-50", "dark:bg-sky-900/20")
    
    // Add active state to selected button
    if (this.selectedTypeValue === "daily") {
      this.dailyButtonTarget.classList.add("ring-2", "ring-sky-500", "border-sky-500", "bg-sky-50", "dark:bg-sky-900/20")
    } else if (this.selectedTypeValue === "menu") {
      this.menuButtonTarget.classList.add("ring-2", "ring-sky-500", "border-sky-500", "bg-sky-50", "dark:bg-sky-900/20")
    }
  }

  showCategoriesFor(type) {
    this.categoryWrapperTarget.classList.remove("hidden")
    this.categoryWrapperTarget.classList.add("animate-fade-in")
    
    // Update the add category link based on selected type
    this.updateAddCategoryLink(type)
    
    // Update the select to show only categories of the selected type
    const options = this.categorySelectTarget.querySelectorAll("option")
    let hasVisibleOption = false
    
    options.forEach(option => {
      if (option.value === "" || option.dataset.categoryType === type) {
        option.style.display = ""
        option.hidden = false
        if (option.value !== "") hasVisibleOption = true
      } else {
        option.style.display = "none"
        option.hidden = true
      }
    })
    
    // Reset selection if current selection is not of the selected type
    const currentOption = this.categorySelectTarget.selectedOptions[0]
    if (currentOption && currentOption.dataset.categoryType && currentOption.dataset.categoryType !== type) {
      this.categorySelectTarget.value = ""
    }
    
    // If no categories exist for this type, show a message
    if (!hasVisibleOption) {
      this.categorySelectTarget.querySelector('option[value=""]').textContent = "No hay categorías disponibles"
    } else {
      this.categorySelectTarget.querySelector('option[value=""]').textContent = "Selecciona una categoría"
    }
  }

  hideCategories() {
    this.categoryWrapperTarget.classList.add("hidden")
    this.categoryWrapperTarget.classList.remove("animate-fade-in")
  }

  hasSelectedCategory() {
    return this.categorySelectTarget.value !== ""
  }

  updateAddCategoryLink(type) {
    const currentHref = this.addCategoryLinkTarget.href
    const baseUrl = currentHref.split('?')[0]
    this.addCategoryLinkTarget.href = `${baseUrl}?selected_type=${type}`
  }
}