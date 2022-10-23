import { Controller } from "@hotwired/stimulus"
import { Modal } from "bootstrap"

export default class extends Controller {
  static targets = ["modal"]

  connect() {
    let backdrop = document.querySelector(".modal-backdrop");
    if (backdrop) {
      backdrop.remove();
    }
    this.modal = new Modal(this.element);
    this.modal.show();
    this.element.addEventListener('hidden.bs.modal', (event) => {
      this.element.remove();
    })
  }

  hideModal() {
    this.element.parentElement.removeAttribute("src");
    this.modalTarget.remove();
  }

  submitEnd(e) {
    if (e.detail.success) {
      this.hideModal();
    }
  }

  closeWithKeyboard(e) {
    if (e.code == "Escape") {
      this.hideModal();
    }
  }

  closeBackground(e) {
    if (e && this.modalTarget.contains(e.target)) {
      return;
    }
    this.hideModal();
  }
}