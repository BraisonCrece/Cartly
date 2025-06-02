import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["submit", "submitText", "spinner"]

  connect() {
    this.originalText = this.submitTextTarget.textContent
  }

  submit() {
    this.submitTarget.disabled = true
    this.submitTextTarget.classList.add("hidden")
    this.spinnerTarget.classList.remove("hidden")
    this.spinnerTarget.classList.add("flex", "items-center")
  }
}