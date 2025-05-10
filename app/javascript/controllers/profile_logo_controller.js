import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = [
    "logoInput",
    "logoWhiteInput",
    "logoLoader",
    "logoWhiteLoader",
    "logoImage",
    "logoWhiteImage",
  ];

  connect() {
    if (this.logoImageTarget.complete) {
      this.imageLoaded();
    }
    if (this.logoWhiteImageTarget.complete) {
      this.imageWhiteLoaded();
    }
  }

  change() {
    const input = this.logoInputTarget;
    const image = this.logoImageTarget;

    if (input.files && input.files[0]) {
      this.logoLoaderTarget.classList.remove("hidden");
      this.logoImageTarget.classList.add("opacity-0");

      const reader = new FileReader();
      reader.onload = (e) => {
        image.src = e.target.result;
      };
      reader.readAsDataURL(input.files[0]);
    }
  }

  changeWhite() {
    const input = this.logoWhiteInputTarget;
    const image = this.logoWhiteImageTarget;

    if (input.files && input.files[0]) {
      this.logoWhiteLoaderTarget.classList.remove("hidden");
      this.logoWhiteImageTarget.classList.add("opacity-0");

      const reader = new FileReader();
      reader.onload = (e) => {
        image.src = e.target.result;
      };
      reader.readAsDataURL(input.files[0]);
    }
  }

  imageLoaded() {
    this.logoLoaderTarget.classList.add("hidden");
    this.logoImageTarget.classList.remove("opacity-0");
  }

  imageWhiteLoaded() {
    this.logoWhiteLoaderTarget.classList.add("hidden");
    this.logoWhiteImageTarget.classList.remove("opacity-0");
  }
}
