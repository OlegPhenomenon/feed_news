import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["presenter"]

  connect() {
  }
  togglePresenter() {
    this.presenterTarget.classList.toggle('d-none');
  }
}
