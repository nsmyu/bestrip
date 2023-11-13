function configureDatePickr() {
  const departureDate = document.querySelector("#departure_date");
  const returnDate = document.querySelector("#return_date");
  const scheduleDate = document.querySelector("#schedule_date");
  const config = { locale: 'ja', altInput: true, altFormat: 'Y/m/j（D）', disableMobile: true };

  function configureMinReturnDate() {
    config.minDate = departureDate.value;
    flatpickr(returnDate, config);
  }

  if (departureDate) {
    flatpickr(departureDate, config);
    flatpickr(returnDate, config);

    departureDate.addEventListener('change', () => {
      configureMinReturnDate()
    });

    if(departureDate.value) {
      configureMinReturnDate()
    }
  }

  if (scheduleDate) {
    config.minDate = departureDate.textContent;
    config.maxDate = returnDate.textContent;
    flatpickr(scheduleDate, config)
  }
}

function configureTimePickr() {
  flatpickr(document.querySelectorAll(".schedule-time"), {
    enableTime  : true,
    noCalendar  : true,
    time_24hr   : true,
    disableMobile: true,
  });
}

document.addEventListener('DOMContentLoaded', () => {
  configureDatePickr();
  configureTimePickr();
})

document.addEventListener('turbo:frame-load', () => {
  configureDatePickr();
  configureTimePickr();
})
