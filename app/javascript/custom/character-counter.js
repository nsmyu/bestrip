function countChars() {
  const textInput = document.querySelector('#text-input');
  const charCount = document.querySelector('#char-count');

  if (!charCount) return;

  const maxCharsLength = charCount.textContent.slice(2);

  function addCharsLengthError() {
    console.log(charCount)
    charCount.classList.add('error-message');
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
      charCount.classList.remove('error-message');
      document.querySelector('#btn-submit').removeAttribute('disabled');
    }
  });
}

document.addEventListener('DOMContentLoaded', countChars)
document.addEventListener('turbo:frame-load', countChars)


