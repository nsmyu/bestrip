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

