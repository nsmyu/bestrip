document.addEventListener('turbo:frame-load', () => {
  const departureDate = document.querySelector("#departure-date-pickr");
  const returnDate = document.querySelector("#return-date-pickr");
  const config = {
    locale       : 'ja',
    dateFormat   : 'Y/m/d（D）',
    disableMobile: true,
	};
  if (!departureDate) return;

  function addMinReturnDate() {
    const departureDateValue = departureDate.value.length === 10
      ? departureDate.value : departureDate.value.slice(0, -3);
    const minReturnDate = new Date(Date.parse(departureDateValue));
    config.minDate = minReturnDate;
    flatpickr('#return-date-pickr', config);
  }

  flatpickr('#return-date-pickr', config);
  flatpickr('#departure-date-pickr', config);

  if(departureDate.value) {
    const returnDateValue = returnDate.value
    addMinReturnDate()
    returnDate.value = returnDateValue
  }

  departureDate.addEventListener('change', () => {
    addMinReturnDate()
  });
});
