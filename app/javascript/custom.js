import { addInputFunction } from "./material_dashboard/material-dashboard";

function countChars() {
  const textInput = document.querySelector('#text-input');
  const charCount = document.querySelector('#char-count');
  if (!textInput) return;

  const maxCharsLength = charCount.textContent.slice(2);

  function addCharsLengthError() {
    textInput.parentElement.classList.add('error-message');
    charCount.previousElementSibling.textContent = maxCharsLength + "文字以内で入力してください";
    document.querySelector("#btn-submit").disabled = true;
  }

  if (textInput.value.length > 0) {
    charCount.querySelector('span').textContent = textInput.value.length;
    if (textInput.value.length > maxCharsLength) {
      addCharsLengthError();
    }
  }

  textInput.addEventListener('input', (e) =>{
    const text = e.target;
    const charsLength = text.value.length;

    if (text) {
      charCount.querySelector('span').textContent = charsLength;
    }

    if (charsLength > maxCharsLength) {
      addCharsLengthError();
    } else {
      textInput.parentElement.classList.remove('error-message');
      charCount.previousElementSibling.textContent = "";
      document.querySelector('#btn-submit').removeAttribute('disabled');
    }
  });
}

function previewImage() {
  const imageInput = document.querySelector('#image-input');
  if (!imageInput) return;

  imageInput.addEventListener('change', (e) =>{
    const file = e.target.files[0];
    const reader = new FileReader();

    reader.onloadend = () => {
      const imagePreview = document.querySelector('#image-preview');
      if(imagePreview) {
        imagePreview.src = reader.result;
      }
    };

    if (file) {
    reader.readAsDataURL(file);
    }
  });
}

document.addEventListener('DOMContentLoaded', () => {
  previewImage();
  countChars();
});

document.addEventListener('turbo:frame-load', () => {
  addInputFunction();
  previewImage();
  countChars();
  const tooltipTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="tooltip"]'))
  const tooltipList = tooltipTriggerList.map(function(tooltipTriggerEl) {
    return new bootstrap.Tooltip(tooltipTriggerEl)
  })
});

// document.addEventListener('turbo:before-render', (e) => {
//   const response = e.detail.fetchResponse.response
//   if (response.redirected) {
//     e.preventDefault()
//     Turbo.visit(e.detail.fetchResponse.response.url, {action: 'advance'})
//   }
// })
