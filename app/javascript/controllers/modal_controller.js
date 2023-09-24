import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.modal = new bootstrap.Modal(this.element)
    this.modal.show()
  }

  close(event) {
    if (event.detail.success) {
      this.modal.hide()

      const response = event.detail.fetchResponse.response
      if (response.redirected) {
        Turbo.visit(response.url, { action: 'advance' })
      }
    }
  }
}

