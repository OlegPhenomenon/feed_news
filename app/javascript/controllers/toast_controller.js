import { Controller } from "@hotwired/stimulus";
import { Toast } from "bootstrap"

export default class extends Controller {
  
  connect() {
    const toastBox = document.querySelector('#toast');
    const toast = new Toast(toastBox);
    toast.show();
  }
}
