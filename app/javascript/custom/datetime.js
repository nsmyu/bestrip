document.addEventListener('turbo:frame-load', () => {
  const departureDate = document.querySelector("#departure-date-pickr");
  const returnDate = document.querySelector("#return-date-pickr");
  const config = {
    locale        : 'ja',
    dateFormat    : 'Y/m/d（D）',
    disableMobile : true,
	};
  if (!departureDate) return;

  function addMinReturnDate() {
    const departureDateValue = departureDate.value.length === 10
      ? departureDate.value : departureDate.value.slice(0, -3);
    const minReturnDate = new Date(Date.parse(departureDateValue));
    config.minDate = minReturnDate;
    flatpickr(returnDate, config);
  }

  flatpickr(returnDate, config);
  flatpickr(departureDate, config);

  if(departureDate.value) {
    const returnDateValue = returnDate.value
    addMinReturnDate()
    returnDate.value = returnDateValue
  }

  departureDate.addEventListener('change', () => {
    addMinReturnDate()
  });
});

document.addEventListener('DOMContentLoaded', () => {
  const scheduleDate = document.querySelector("#schedule-date-pickr");
  const departureDate = document.querySelector("#departure-date");
  const returnDate = document.querySelector("#return-date");
  const minScheduleDate = new Date(Date.parse(departureDate.textContent));
  const maxScheduleDate = new Date(Date.parse(returnDate.textContent));
  const time = document.querySelectorAll(".time-pickr");

  flatpickr(scheduleDate, {
    locale        : 'ja',
    dateFormat    : 'Y/m/d（D）',
    disableMobile : true,
    minDate       : minScheduleDate,
    maxDate       : maxScheduleDate,
  });

  flatpickr(time, {
    enableTime  : true,
    noCalendar  : true,
    dateFormat  : "H:i",
    time_24hr   : true,
  });
});
