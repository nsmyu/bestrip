import { Controller } from "@hotwired/stimulus"

const MAX_PHOTOS_COUNT_PER_POST = 20;

export default class extends Controller {
  static targets = ["form", "field", "preview", "imageBox", "submit"]

  connect() {
    const registeredPhotosHiddenFields = document.querySelectorAll(`[id^='post_photos_attributes']`);

    if (registeredPhotosHiddenFields.length == 0) {
      this.fieldTargets[0].classList.add("active-field");
    } else if (registeredPhotosHiddenFields.length == MAX_PHOTOS_COUNT_PER_POST) {
      this.fieldTargets[0].classList.add("active-field");
      this.fieldTargets[0].parentElement.classList.add("disabled");
    } else {
      const lastRegisterdPhotoFieldId = Number(this.fieldTargets.slice(-1)[0].id.replace(/photo_field_/g, ''));
      this.createNextField(lastRegisterdPhotoFieldId);
    }
  }

  selectPhotos() {
    const activeField = document.querySelector(".active-field");
    const activeFieldId = Number(activeField.id.replace(/photo_field_/g, ''));
    const file = activeField.files[0];

    this.previewPhoto(file, activeFieldId);

    if (this.imageBoxTargets.length < (MAX_PHOTOS_COUNT_PER_POST - 1)) {
      this.createNextField(activeFieldId);
      activeField.classList.remove("active-field");
    } else {
      activeField.parentElement.classList.add("disabled");
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
      img.setAttribute("class", "post-photo-preview");
      imgBox.setAttribute("class", "col-3 p-1 position-relative");
      imgBox.setAttribute("data-post-photos-target", "imageBox");
      deleteBtn.setAttribute("class", "position-absolute top-5 end-5 link cursor-pointer");
      deleteBtn.setAttribute("id", `delete_btn_${fieldId}`);
      deleteBtn.setAttribute("data-action", "click->post-photos#deletePhoto");
      deleteBtnIcon.setAttribute("class", "material-icons text-white bg-dark rounded-circle");
      deleteBtnIcon.textContent = "close";

      imgBox.appendChild(img);
      deleteBtn.appendChild(deleteBtnIcon);
      imgBox.appendChild(deleteBtn);
      this.previewTarget.appendChild(imgBox);
    };
  }

  deletePhoto(event) {
    const target = event.currentTarget;
    const targetId = Number(target.id.replace(/delete_btn_/g, ''));
    const targetPhotoHiddenField = document.querySelector(`#post_photos_attributes_${targetId}_id`);
    const activeField = document.querySelector(".active-field");

    target.parentElement.remove();
    document.querySelector(`#photo_field_${targetId}`).parentElement.remove();

    if (targetPhotoHiddenField) {
      const destroyField = document.createElement("input");

      destroyField.value = true;
      destroyField.setAttribute("class", "d-none");
      destroyField.setAttribute("name", `post[photos_attributes][${targetId}][_destroy]`);
      this.formTarget.appendChild(destroyField);
    }

    const emptyFields = this.fieldTargets.filter(field => !field.value);

    if (emptyFields.length > 0){
      if (activeField) {
        document.querySelector(".active-field").parentElement.classList.remove("disabled");
        return;
      } else {
        emptyFields[0].classList.add("active-field");
      }
    } else {
      const lastFieldId = Number(this.fieldTargets.slice(-1)[0].id.replace(/photo_field_/g, ''));

      this.createNextField(lastFieldId);

      if (activeField) {
        activeField.classList.remove("active-field");
      }
    }
  }

  createNextField(id) {
    const nextFieldNode = this.fieldTargets[0].parentElement.cloneNode(true);

    nextFieldNode.setAttribute("for", `photo_field_${id + 1}`);
    nextFieldNode.classList.remove("disabled");
    nextFieldNode.children[1].value = null;
    nextFieldNode.children[1].setAttribute("class", "d-none active-field");
    nextFieldNode.children[1].setAttribute("id", `photo_field_${id + 1}`);
    nextFieldNode.children[1].setAttribute("name", `post[photos_attributes][${id + 1}][url]`);
    this.formTarget.appendChild(nextFieldNode);
  }
}
