const bootstrapConfirm = (message) => {
  const modalElement = document.querySelector('#turbo-confirm-modal');
  const confirmMessage = document.querySelector('#turbo-confirm-modal-message');
  const confirmButton = document.querySelector('#turbo-confirm-modal-confirm-button');
  const modal = new bootstrap.Modal(modalElement);

  confirmMessage.textContent = message;
  modal.show();

  return new Promise((resolve) => {
    confirmButton.addEventListener('click', () => {
      resolve(true);
      modal.hide();
    }, {
      once: true
    });
  });
}

Turbo.setConfirmMethod(bootstrapConfirm);
