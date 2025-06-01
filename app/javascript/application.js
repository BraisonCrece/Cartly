// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails";
import "controllers";

// Custom Turbo Stream actions using event listener approach
addEventListener("turbo:before-stream-render", (event) => {
  const fallbackToDefaultActions = event.detail.render;

  event.detail.render = function (streamElement) {
    if (streamElement.action === "clear_form") {
      const target = streamElement.getAttribute("target");
      const element = document.getElementById(target);

      if (element) {
        if (element.tagName === "FORM") {
          element.reset();
        } else if (
          element.tagName === "INPUT" ||
          element.tagName === "TEXTAREA"
        ) {
          element.value = "";
        } else {
          const inputs = element.querySelectorAll("input, textarea, select");
          inputs.forEach((input) => {
            if (input.type === "checkbox" || input.type === "radio") {
              input.checked = false;
            } else {
              input.value = "";
            }
          });
        }
      }
    } else {
      fallbackToDefaultActions(streamElement);
    }
  };
});
