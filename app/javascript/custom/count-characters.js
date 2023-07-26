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
