function countChars() {
  const textInput = document.querySelector('#text-input');
  const charCount = document.querySelector('#char-count');

  if (!charCount) return;

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

document.addEventListener('DOMContentLoaded', countChars)
document.addEventListener('turbo:frame-load', countChars)

