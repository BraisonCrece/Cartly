import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="profile-logo"
export default class extends Controller {
  static targets = ['input', 'image']

  change() {
    const input = this.inputTarget
    const image = this.imageTarget

    if (input.files && input.files[0]) {
      const reader = new FileReader()
      reader.onload = e => {
        image.src = e.target.result
      }
      reader.readAsDataURL(input.files[0])
    }
  }
}
