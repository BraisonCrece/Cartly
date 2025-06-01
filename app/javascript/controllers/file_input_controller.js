import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="file-input"
export default class extends Controller {
  static targets = ["fileInput", "fileName", "imagePreview", "placeholderUrl"]

  updateFile() {
    const input = this.fileInputTarget
    const fileName =
      input.files.length > 0 ? input.files[0].name : "Selecciona un archivo..."
    this.fileNameTarget.innerText = fileName
    
    if (fileName === "Selecciona un archivo...") {
      this.fileNameTarget.classList.add("text-gray-400")
      this.fileNameTarget.classList.remove("text-gray-900", "dark:text-white")
    } else {
      this.fileNameTarget.classList.remove("text-gray-400")
      this.fileNameTarget.classList.add("text-gray-900", "dark:text-white")
    }

    if (input.files && input.files[0]) {
      const reader = new FileReader()
      reader.onload = e => {
        this.imagePreviewTarget.src = e.target.result
      }
      reader.readAsDataURL(input.files[0])
    }
  }

  changePicture() {
    this.fileInputTarget.click()
  }
}
