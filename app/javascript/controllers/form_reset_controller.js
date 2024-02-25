import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input"]

  clear() {
    for (const inputTarget of this.inputTargets) {
      inputTarget.value = null;
      inputTarget.parentElement.classList.remove("is-filled");
    }
  }
}
