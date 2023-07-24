document.addEventListener('turbo:load', () => {
  const imageInput = document.querySelector('#image-input');
  const imagePreview = document.querySelector('#image-preview');

  imageInput.addEventListener('change', (e) => {
    const file = e.target.files[0];
    const reader = new FileReader();

    reader.onloadend = () => {
      imagePreview.src = reader.result;
    };

    reader.readAsDataURL(file);
  });
});
