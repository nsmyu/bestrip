function configureDatePickr() {
  const departureDate = document.querySelector("#departure_date");
  const returnDate = document.querySelector("#return_date");
  const scheduleDate = document.querySelector("#schedule_date");
  const config = {
    locale        : 'ja',
    dateFormat    : 'Y/m/d（D）',
    disableMobile : true,
	};

  if (departureDate) {
    function addMinReturnDate() {
      const departureDateValue = departureDate.value.length === 10
        ? departureDate.value : departureDate.value.slice(0, -3);
      const minReturnDate = new Date(Date.parse(departureDateValue));
      config.minDate = minReturnDate;
      flatpickr(returnDate, config);
    }

    flatpickr(departureDate, config);
    flatpickr(returnDate, config);

    if(departureDate.value) {
      const returnDateValue = returnDate.value
      addMinReturnDate()
      returnDate.value = returnDateValue
    }

    departureDate.addEventListener('change', () => {
      addMinReturnDate()
    });
  }

  if (scheduleDate) {
    const minScheduleDate = new Date(Date.parse(departureDate.textContent));
    const maxScheduleDate = new Date(Date.parse(returnDate.textContent));
    config.minDate = minScheduleDate
    config.maxDate = maxScheduleDate

    if (scheduleDate.value) {
      const scheduleDateValue = scheduleDate.value
      flatpickr(scheduleDate, config);
      scheduleDate.value = scheduleDateValue
    } else {
      flatpickr(scheduleDate, config);
    }
  }
}

function configureTimePickr() {
  const scheduleTime = document.querySelectorAll(".schedule-time");

  flatpickr(scheduleTime, {
    enableTime  : true,
    noCalendar  : true,
    dateFormat  : "H:i",
    time_24hr   : true,
  });
}

document.addEventListener('DOMContentLoaded', () => {
  configureDatePickr();
  configureTimePickr();
});

document.addEventListener('turbo:frame-load', () => {
  configureDatePickr();
  configureTimePickr();
});
