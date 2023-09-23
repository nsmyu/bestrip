function initAutocomplete() {
  const input = document.getElementById('autocomplete_text_input');

  if (!input) return;

  const placeInfoCard = document.getElementById("place_info_card");
  const emptyplaceInfoCard = document.getElementById("empty_place_info_card");
  const placeId = document.getElementById("place_id");
  const options = {
    fields: ["name", "formatted_address", "photos", "place_id"],
  };
  const autocomplete = new google.maps.places.Autocomplete(input, options);

  autocomplete.addListener('place_changed', () => {
    const place = autocomplete.getPlace();

    if (!place) return;

    const placeName = document.getElementById("place_name");
    const placeAddress = document.getElementById("place_address");
    const placePhoto = document.getElementById("place_photo");
    const mapFrame = document.getElementById("map_frame")

    emptyplaceInfoCard.style.display = "none"
    placeInfoCard.style.display = "block"
    placeId.value = place.place_id
    placeName.textContent = place.name
    placeAddress.textContent = place.formatted_address
    mapFrame.setAttribute('src', mapFrame.src.split(/place_id:/)[0] + `place_id:${place.place_id}`)

    if (place.photos) {
      placePhoto.setAttribute('src', place.photos[0].getUrl())
    } else {
      placePhoto.setAttribute('src', "/assets/default_schedule_thumbnail.png")
    }
  })

  document.getElementById("reset_place_btn").addEventListener("click", () => {
    placeId.value = null;
    emptyplaceInfoCard.style.display = "block";
    placeInfoCard.style.display = "none";
  })

  if (placeId && placeId.value) {
    emptyplaceInfoCard.style.display = "none";
    placeInfoCard.style.display = "block";
  }
}

document.addEventListener('DOMContentLoaded', initAutocomplete);
document.addEventListener('turbo:frame-load', initAutocomplete);
