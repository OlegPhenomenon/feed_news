// app/javascript/controllers/debounce_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["form"]

    connect() {
        console.log();
    }

    search(event) {
        // console.log(event.detail.url);
        clearTimeout(this.timeout)
        this.timeout = setTimeout(() => {
            this.formTarget.requestSubmit()
        }, 500)
    }
}
