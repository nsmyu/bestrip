import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["form", "field", "preview", "photoBox", "submit"]

  selectPhotos(){
    const activeField = document.querySelector(".active-field")
    const id = Number(activeField.id.replace(/photo_field_/g, ''))
    const file = activeField.files[0]

    if (this.photoBoxTargets.length < 4) {
      const nextField = activeField.parentElement.cloneNode(true)
      nextField.setAttribute("for", `photo_field_${id + 1}`)
      nextField.children[1].value = null
      nextField.children[1].setAttribute("id", `photo_field_${id + 1}`)
      nextField.children[1].classList.add("active-field")
      nextField.children[1].setAttribute("name", `post[photos_attributes][${id + 1}][url]`)
      this.formTarget.appendChild(nextField)
      activeField.classList.remove("active-field")
    } else {
      activeField.parentElement.classList.add("disabled")
    }

    this.previewPhoto(file, id)
  }

  previewPhoto(file, id){
    const preview = this.previewTarget
    const reader = new FileReader();
    reader.readAsDataURL(file);
    reader.onloadend = () => {
      const img = new Image()
      const imgBox = document.createElement("div")
      const deleteBtn = document.createElement("a")
      const deleteBtnIcon = document.createElement("i")

      img.src = reader.result
      img.setAttribute("class", "post-photo-preview")
      imgBox.setAttribute("class", "col-3 p-1 position-relative")
      imgBox.setAttribute("data-photos-target", "photoBox")
      deleteBtn.setAttribute("class", "position-absolute top-5 end-5 link cursor-pointer")
      deleteBtn.setAttribute("id", `delete_btn_${id}`)
      deleteBtn.setAttribute("data-action", "click->photos#deletePhoto")
      deleteBtnIcon.textContent = "close"
      deleteBtnIcon.setAttribute("class", "material-icons text-white bg-dark rounded-circle")

      imgBox.appendChild(img)
      deleteBtn.appendChild(deleteBtnIcon)
      imgBox.appendChild(deleteBtn)
      preview.appendChild(imgBox)
    };
  }

  deletePhoto(event){
    const deleteTarget = event.currentTarget
    const deleteTargetId = Number(deleteTarget.id.replace(/delete_btn_/g, ''))
    const deleteTargetField = document.querySelector(`#photo_field_${deleteTargetId}`)

    deleteTarget.parentElement.remove()
    deleteTargetField.parentElement.remove()

    const emptyFields = this.fieldTargets.filter(field => !field.value)

    if (emptyFields.length > 0) {
      emptyFields[0].classList.add("active-field")
    } else {
      const lastFieldId = Number(this.fieldTargets.slice(-1)[0].id.replace(/photo_field_/g, ''))
      const activeField = document.querySelector(".active-field")
      const nextField = this.fieldTargets[0].parentElement.cloneNode(true)
      nextField.setAttribute("for", `photo_field_${lastFieldId + 1}`)
      nextField.children[1].value = null
      nextField.children[1].setAttribute("id", `photo_field_${lastFieldId + 1}`)
      nextField.children[1].classList.add("active-field")
      nextField.children[1].setAttribute("name", `post[photos_attributes][${lastFieldId + 1}][url]`)
      nextField.children[1].disabled = false
      nextField.classList.remove("disabled")
      this.formTarget.appendChild(nextField)
      if (activeField) {
        activeField.classList.remove("active-field")
      }
    }
  }
}
