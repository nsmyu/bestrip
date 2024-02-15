import { Controller } from "@hotwired/stimulus"

export default class extends Controller {

  markComment(event) {
    this.unmarkComment();

    const replyTarget = event.currentTarget;
    const targetCommentId = replyTarget.id.replace(/reply_btn_to_/, '');
    const targetCommentBody = document.querySelector(`#comment_body_${targetCommentId}`);

    targetCommentBody.classList.remove("bg-gray-200");
    targetCommentBody.classList.add("bg-primary-opacity");
  }

  unmarkComment() {
    const previousTarget = document.getElementsByClassName("bg-primary-opacity");

    if (previousTarget[0]) {
      previousTarget[0].classList.add("bg-gray-200");
      previousTarget[0].classList.remove("bg-primary-opacity");
    }
  }

  activateSubmitBtn(event) {
    const input = event.currentTarget;
    const submitBtn = document.querySelector("#submit_btn");

    if ((input.value.trim().length > 0) && (input.value.length < 1001)) {
      submitBtn.disabled = false;
      submitBtn.classList.remove("text-secondary");
      submitBtn.classList.add("text-primary", "hover-opacity");
    } else {
      submitBtn.disabled = true;
      submitBtn.classList.remove("text-primary", "hover-opacity");
      submitBtn.classList.add("text-secondary");
    }
  }
}
