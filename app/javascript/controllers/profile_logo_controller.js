import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["input", "image", "loader"];

  connect() {
    if (this.imageTarget.complete) {
      this.imageLoaded();
    }
  }

  change() {
    const input = this.inputTarget;
    const image = this.imageTarget;

    if (input.files && input.files[0]) {
      this.loaderTarget.classList.remove("hidden");
      this.imageTarget.classList.add("opacity-0");

      const reader = new FileReader();
      reader.onload = (e) => {
        image.src = e.target.result;
      };
      reader.readAsDataURL(input.files[0]);
    }
  }

  imageLoaded() {
    this.loaderTarget.classList.add("hidden");
    this.imageTarget.classList.remove("opacity-0");
  }
}
