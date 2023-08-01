document.addEventListener('turbo:frame-load', () => {
  const departureDate = document.querySelector("#departure-date-pickr");
  const config = {
    locale       : 'ja',
    dateFormat   : 'Y/m/d（D）',
    disableMobile: true,
	};

  departureDate.addEventListener('change', (e) => {
    const date = e.target.value.slice(0, -3);
    const minReturnDate = new Date(Date.parse(date));
    config.minDate = minReturnDate;
    flatpickr('#return-date-pickr', config);
  });

  flatpickr('#return-date-pickr', config);
  flatpickr('#departure-date-pickr', config);
});
