import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = [
    "input",
    "output",
    "spinner",
    "buttonText",
    "descriptionImage",
    "button",
  ];

  connect() {
    this.updateButtonState();
  }

  validateInputs() {
    this.updateButtonState();
  }

  async describe(e) {
    e.preventDefault();
    const type = e.currentTarget.dataset.type;
    const text = this.inputTarget.value;
    let imageBase64 = "";

    if (type !== "wine" && this.descriptionImageTarget.files[0]) {
      imageBase64 = await this.convertToBase64(
        this.descriptionImageTarget.files[0],
      );
    }

    const descriptionType = this.getDescriptionType(type);
    const requestOptions = this.buildRequestOptions(text, {
      image: imageBase64,
      description_type: descriptionType,
    });

    await this.fetchDescription(requestOptions);
  }

  async fetchDescription(requestOptions) {
    this.showSpinner();
    try {
      const response = await fetch("/describe_dish", requestOptions);
      if (!response.ok)
        throw new Error(`HTTP error! Status: ${response.status}`);

      const { description } = await response.json();
      this.outputTarget.value = description;
    } catch (error) {
      console.error("Error fetching description:", error);
    } finally {
      this.hideSpinner();
    }
  }

  convertToBase64(file) {
    return new Promise((resolve, reject) => {
      const reader = new FileReader();
      reader.readAsDataURL(file);
      reader.onload = () => resolve(reader.result);
      reader.onerror = (error) => reject(error);
    });
  }

  buildRequestOptions(text, options = {}) {
    return {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": this.getCSRFToken(),
      },
      body: JSON.stringify({
        plato: text,
        ...options,
      }),
    };
  }

  getCSRFToken() {
    return document.querySelector('meta[name="csrf-token"]').content;
  }

  showSpinner() {
    this.spinnerTarget.classList.remove("hidden");
    this.spinnerTarget.classList.add("flex");
    this.buttonTextTarget.classList.add("hidden");
  }

  hideSpinner() {
    this.spinnerTarget.classList.add("hidden");
    this.spinnerTarget.classList.remove("flex");
    this.buttonTextTarget.classList.remove("hidden");
  }

  updateButtonState() {
    const hasName = this.inputTarget.value.trim().length > 0;
    const hasImage = this.hasDescriptionImageTarget && this.descriptionImageTarget.files.length > 0;
    
    const isValid = hasName || hasImage;
    
    this.buttonTarget.disabled = !isValid;
    this.buttonTarget.classList.toggle("opacity-50", !isValid);
    this.buttonTarget.classList.toggle("cursor-not-allowed", !isValid);
  }

  getDescriptionType(type) {
    switch (type) {
      case "wine":
        return "vino";
      case "drink":
        return "bebida";
      default:
        return "plato";
    }
  }
}
