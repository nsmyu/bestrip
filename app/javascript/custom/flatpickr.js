function configureDatePickr() {
  const departureDate = document.querySelector("#departure-date");
  const returnDate = document.querySelector("#return-date");
  const scheduleDate = document.querySelector("#schedule-date");
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

    if (scheduleDate) {
      const minScheduleDate = new Date(Date.parse(departureDate.textContent));
      const maxScheduleDate = new Date(Date.parse(returnDate.textContent));

      flatpickr(scheduleDate, {
        locale        : 'ja',
        dateFormat    : 'Y/m/d（D）',
        disableMobile : true,
        minDate       : minScheduleDate,
        maxDate       : maxScheduleDate,
      });
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

document.addEventListener('turbo:frame-load', () => {
  configureDatePickr();
  configureTimePickr();
});

