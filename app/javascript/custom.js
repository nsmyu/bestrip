import { addInputFunction } from "./material_dashboard/material-dashboard";

function countChars() {
  const textInput = document.querySelector('#text-input');
  const charCount = document.querySelector('#char-count');
  const maxCharsLength = charCount.textContent.slice(2);
  const initialCharsLength = textInput.value.length;

  function addCharsLengthError() {
    textInput.parentElement.classList.add('error-message');
    charCount.previousElementSibling.textContent = maxCharsLength + "文字以内で入力してください";
    document.querySelector("#btn-submit").disabled = true;
  }

  if (initialCharsLength > 0) {
    charCount.querySelector('span').textContent = initialCharsLength;
    if (initialCharsLength > maxCharsLength) {
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
  const path = location.pathname;
  if (path == "/users/edit_profile") {
    previewImage();
    countChars();
  }
});

document.addEventListener('turbo:frame-load', () => {
  const path = location.pathname;
  if (path === "/users/edit_profile") {
    addInputFunction();
    previewImage();
    countChars();
    const tooltipTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="tooltip"]'))
    const tooltipList = tooltipTriggerList.map(function(tooltipTriggerEl) {
      return new bootstrap.Tooltip(tooltipTriggerEl)
    })
  }
  if (path === "/itineraries") {
    previewImage();
  }
});

document.addEventListener('turbo:before-fetch-response', (event) => {
  const response = event.detail.fetchResponse.response
  if (response.redirected) {
    event.preventDefault()
    Turbo.visit(event.detail.fetchResponse.response.url, {action: 'advance'})
  }
})
