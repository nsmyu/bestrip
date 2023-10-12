import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "preview"]

  selectPhotos(){
    const activeField = document.querySelector(".active-field")
    const id = Number(activeField.id.replace(/photo_input_/g, ''))
    const file = activeField.files[0]
    const emptyInputs = this.inputTargets.filter(input => !input.value)

    if (emptyInputs.length > 0) {
      emptyInputs[0].classList.add("active-field")
      activeField.classList.remove("active-field")
    } else {
      activeField.disabled = true
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
    const previewToDelete = event.currentTarget
    const inputToDelete = document.querySelector(`#photo_input_${ previewToDelete.id.replace(/delete_btn_/g, '') }`)

    previewToDelete.parentElement.remove()
    document.querySelector(".active-field").classList.remove("active-field")
    inputToDelete.value = ""
    inputToDelete.disabled = false
    inputToDelete.parentElement.classList.remove("disabled")
    inputToDelete.classList.add("active-field")
  }
}

