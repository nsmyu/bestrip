function previewImage() {
  const imageInput = document.querySelector('#image_input');

  if (imageInput) {
    imageInput.addEventListener('change', (e) =>{
      const file = e.target.files[0];
      const reader = new FileReader();
      reader.readAsDataURL(file);
      reader.onloadend = () => {
        const imagePreview = document.querySelector('#image_preview');
        imagePreview.src = reader.result;
      };
    });
  }
}

document.addEventListener('DOMContentLoaded', previewImage);
document.addEventListener('turbo:frame-load', previewImage);
