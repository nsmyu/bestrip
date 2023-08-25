function previewImage() {
  const imageInput = document.querySelector('#image_input');

  if (imageInput) {
    imageInput.addEventListener('change', (e) =>{
      const file = e.target.files[0];
      const reader = new FileReader();

      reader.onloadend = () => {
        const imagePreview = document.querySelector('#image_preview');
        if(imagePreview) {
          imagePreview.src = reader.result;
        }
      };

      if (file) {
        reader.readAsDataURL(file);
      }
    });
  }
}

document.addEventListener('DOMContentLoaded', previewImage);
document.addEventListener('turbo:frame-load', previewImage);
