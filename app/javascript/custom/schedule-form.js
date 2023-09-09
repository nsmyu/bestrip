document.addEventListener('turbo:frame-load', () => {
  const scheduleForm = document.querySelector('#schedule-form');

  if (scheduleForm) {
    scheduleForm.onkeypress = (e) => {
      if (e.key === "Enter") {
        e.preventDefault();
      }
    }

    const itineraryId = scheduleForm.dataset.itineraryId

    document.querySelector("#query-input").addEventListener('input', () => {
      scheduleForm.action = `/itineraries/${itineraryId}/search_place`;
      scheduleForm.method = "get";
      scheduleForm.dataset.turboFrame = "places_within_schedule_form";
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

    const addPlaceBtn = document.querySelector('#add-place-btn')
    const placeIds = document.getElementsByName("place_id")
    const removePlaceBtn = document.querySelector('#remove-place-btn')

    for(let p of placeIds) {
      p.addEventListener('change', () => {
        scheduleForm.action = `/itineraries/${itineraryId}/add_place_to_schedule`;
        scheduleForm.method = "get";
        scheduleForm.dataset.turboFrame = "spot";
        addPlaceBtn.click();
      })
    }

    if (removePlaceBtn) {
      removePlaceBtn.addEventListener('click', () => {
        scheduleForm.action = `/itineraries/${itineraryId}/remove_place_from_schedule`;
        scheduleForm.method = "get";
        scheduleForm.dataset.turboFrame = "spot";
      })
    }

    const submitBtn = document.querySelector('#sumit-btn')

    submitBtn.addEventListener('click', () => {
      scheduleForm.action = `/itineraries/${itineraryId}/schedules`;
      scheduleForm.method = "post";
      delete scheduleForm.dataset.turboFrame;
      scheduleForm.dataset.action = "turbo:submit-end->modal#close";
    })
  }
})
