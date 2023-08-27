document.addEventListener('turbo:frame-load', () => {
  const scheduleForm = document.querySelector('#schedule-form');

  if (scheduleForm) {
    const itineraryId = scheduleForm.dataset.itineraryId

    document.querySelector("#query-input").addEventListener('input', () => {
      scheduleForm.action = `/itineraries/${itineraryId}/search_place`;
      scheduleForm.method = "get";
      scheduleForm.dataset.turboFrame = "place_within_schedule_form";
      scheduleForm.dataset.controller = "search-form";
      scheduleForm.dataset.action = "input->search-form#submit";
    })

    document.querySelector("#query-input").addEventListener('focusout', () => {
      scheduleForm.action = `/itineraries/${itineraryId}/schedules`;
      scheduleForm.method = "post";
      delete scheduleForm.dataset.turboFrame;
      delete scheduleForm.dataset.controller;
      delete scheduleForm.dataset.action;
    })
  }

  const addPlaceBtn = document.querySelector('#add-place-btn')
  const placeIds = document.getElementsByName("place_id")

  for(let p of placeIds) {
    p.addEventListener('change', () => {
      addPlaceBtn.click();
    })
  }
})
