import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["form", "select", "submit"]

  setItinerary() {
    const selectedItineraryId = this.selectTarget.value;

    this.formTarget.action = `/itineraries/${selectedItineraryId}/places/from_user_to_itinerary`;

    if (selectedItineraryId != 0) {
      this.submitTarget.disabled = false;
    } else {
      this.submitTarget.disabled = true;
    }
  }
}
