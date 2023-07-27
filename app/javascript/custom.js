document.addEventListener('turbo:load', () => {
  const counted = document.querySelector('.counted');
  const inputCount = document.querySelector('.input-count');
  const maxLength = inputCount.textContent.slice(2)

  counted.addEventListener('input', (e) =>{
    const text = e.target;
    const textLength = text.value.length;

    if (text) {
      inputCount.querySelector('span').textContent = textLength;
    }

    if (textLength > maxLength) {
      inputCount.parentElement.classList.add('error-message');
      inputCount.previousElementSibling.textContent = maxLength + "文字以内で入力してください"
      document.querySelector("#btn-submit").disabled = true;
    } else {
      inputCount.parentElement.classList.remove('error-message');
      inputCount.previousElementSibling.textContent = "";
      document.querySelector('#btn-submit').removeAttribute('disabled');
    }
  });
});

document.addEventListener('turbo:frame-load', () => {
  const imageInput = document.querySelector('#image-input');
  const imagePreview = document.querySelector('#image-preview');

  imageInput.addEventListener('change', (e) => {
    const file = e.target.files[0];
    const reader = new FileReader();

    reader.onloadend = () => {
      imagePreview.src = reader.result;
    };

    if (file) {
    reader.readAsDataURL(file);
    }
  });
});

// function previewImage() {
//   const target = this.event.target;
//   const file = target.files[0];
//   const reader  = new FileReader();
//   reader.onloadend = function () {
//       const preview = document.querySelector("#image-preview")
//       if(preview) {
//           preview.src = reader.result;
//       }
//   }
//   if (file) {
//       reader.readAsDataURL(file);
//   }
// }

document.querySelector('#image-input').onchange = (e) => {
  const file = e.target.files[0];
  const reader = new FileReader();
  const imagePreview = document.querySelector('#image-preview');
  console.log("ok")
    reader.onloadend = () => {
      imagePreview.src = reader.result;
    };

    if (file) {
    reader.readAsDataURL(file);
    };
  };
