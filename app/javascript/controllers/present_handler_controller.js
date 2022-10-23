import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  connect() {
    console.log('togglePresenter');
  }
  togglePresenter() {
    console.log('togglePresenter click');

    const present = document.querySelector('#present');
    present.classList.toggle('d-none');
  }
}
