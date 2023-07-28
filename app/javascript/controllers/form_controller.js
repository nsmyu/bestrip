import { Controller } from "@hotwired/stimulus"

import { addInputFunction } from "../material_dashboard/material-dashboard"
import * as custom from "../custom"

export default class extends Controller {

  setDynamicEffects() {
    addInputFunction();
    custom.previewImage();
    custom.countChars();
  }
};
