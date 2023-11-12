import { Controller } from "@hotwired/stimulus"

const MAX_PHOTOS_COUNT_PER_POST = 20;

export default class extends Controller {
  static targets = ["form", "photoField", "titleField", "preview", "imageBox"]

  connect() {
    const registeredPhotosHiddenFields = document.querySelectorAll(`[id^='post_photos_attributes']`);

    if (registeredPhotosHiddenFields.length == 0) {
      this.photoFieldTarget.classList.add("active-field");
    } else {
      const lastRegisterdPhotoFieldId = Number(this.photoFieldTargets.slice(-1)[0].id.replace(/photo_field_/g, ''));
      this.createNextField(lastRegisterdPhotoFieldId);

      if (registeredPhotosHiddenFields.length == MAX_PHOTOS_COUNT_PER_POST) {
        document.querySelector(".active-field").parentElement.classList.add("disabled");
      }
    }
  }

  setTitle(event) {
    const selectBox = event.currentTarget;
    const selectedIndex = selectBox.selectedIndex;
    this.titleFieldTarget.value = selectBox.options[selectedIndex].textContent;
  }

  selectPhotos(event) {
    const currentField = event.currentTarget;
    const currentFieldId = Number(currentField.id.replace(/photo_field_/g, ''));
    const file = currentField.files[0];

    this.previewPhoto(file, currentFieldId);
    currentField.classList.remove("active-field");
    this.createNextField(currentFieldId);

    if (this.imageBoxTargets.length == (MAX_PHOTOS_COUNT_PER_POST - 1)) {
      document.querySelector(".active-field").parentElement.classList.add("disabled");
    }
  }

  previewPhoto(file, fieldId) {
    const reader = new FileReader();
    reader.readAsDataURL(file);

    reader.onloadend = () => {
      const img = new Image();
      const imgBox = document.createElement("div");
      const deleteBtn = document.createElement("a");
      const deleteBtnIcon = document.createElement("i");

      img.src = reader.result;
      img.setAttribute("class", "square-image");
      imgBox.setAttribute("class", "col-3 p-1 position-relative");
      imgBox.setAttribute("data-post-form-target", "imageBox");
      deleteBtn.setAttribute("class", "position-absolute top-5 end-5 link cursor-pointer");
      deleteBtn.setAttribute("id", `delete_btn_${fieldId}`);
      deleteBtn.setAttribute("data-action", "click->post-form#deletePhoto");
      deleteBtnIcon.setAttribute("class", "material-icons text-white bg-dark rounded-circle");
      deleteBtnIcon.textContent = "close";

      imgBox.appendChild(img);
      deleteBtn.appendChild(deleteBtnIcon);
      imgBox.appendChild(deleteBtn);
      this.previewTarget.appendChild(imgBox);
    };
  }

  deletePhoto(event) {
    const deleteTarget = event.currentTarget;
    const deleteTargetId = Number(deleteTarget.id.replace(/delete_btn_/g, ''));
    const deleteTargetHiddenField = document.querySelector(`#post_photos_attributes_${deleteTargetId}_id`);

    deleteTarget.parentElement.remove();
    document.querySelector(`#photo_field_${deleteTargetId}`).parentElement.remove();

    if (deleteTargetHiddenField) {
      const destroyField = document.createElement("input");

      destroyField.value = true;
      destroyField.setAttribute("class", "d-none");
      destroyField.setAttribute("name", `post[photos_attributes][${deleteTargetId}][_destroy]`);
      this.formTarget.appendChild(destroyField);
    }

    document.querySelector(".active-field").parentElement.classList.remove("disabled");
  }

  createNextField(id) {
    const nextFieldNode = this.photoFieldTargets[0].parentElement.cloneNode(true);

    nextFieldNode.setAttribute("for", `photo_field_${id + 1}`);
    nextFieldNode.classList.remove("disabled");
    nextFieldNode.children[1].value = null;
    nextFieldNode.children[1].setAttribute("class", "d-none active-field");
    nextFieldNode.children[1].setAttribute("id", `photo_field_${id + 1}`);
    nextFieldNode.children[1].setAttribute("name", `post[photos_attributes][${id + 1}][url]`);
    this.formTarget.appendChild(nextFieldNode);
  }
}
