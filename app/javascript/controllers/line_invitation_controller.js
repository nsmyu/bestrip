import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  popupWindow() {
    const requestUrl = document.querySelector("#request_url").href;
    if (window.innerWidth > 950) {
      const wTop = window.screenTop + (window.innerHeight / 2) - 250;
      const wLeft = window.screenLeft + (window.innerWidth / 2) - 250;
      window.open(requestUrl, null, 'width=500, height=500, top=' + wTop + ', left=' + wLeft + ', personalbar=0, toolbar=0, scrollbars=1, resizable=!');
    } else {
      window.location.href = requestUrl;
    }
  }
}
