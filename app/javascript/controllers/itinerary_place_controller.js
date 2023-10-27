import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["form", "select", "submit"]

  setItinerary() {
    const selectedItineraryId = this.selectTarget.value;

    this.formTarget.action = `/itineraries/${selectedItineraryId}/places/add_from_user_places`;

    if (selectedItineraryId != 0) {
      this.submitTarget.disabled = false;
    } else {
      this.submitTarget.disabled = true;
    }
  }
}
