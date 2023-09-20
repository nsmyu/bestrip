function googlePlacesAutocomplete() {
  const placeId = document.getElementById("place_id");
  const placeInfoCard = document.getElementById("place_info_card");
  const emptyplaceInfoCard = document.getElementById("empty_place_info_card");

  if(placeId.value) {
    emptyplaceInfoCard.style.display = "none"
    placeInfoCard.style.display = "block"
  }

  const resetPlaceBtn = document.getElementById("reset_place_btn");
  if(resetPlaceBtn) {
    resetPlaceBtn.addEventListener("click", () => {
      placeId.value = null;
      emptyplaceInfoCard.style.display = "block";
      placeInfoCard.style.display = "none";
    })
  }

  const input = document.getElementById('query_input');
  const options = {
    fields: ["name", "formatted_address", "photos", "place_id"],
  };

  if(input) {
    const autocomplete = new google.maps.places.Autocomplete(input, options);
    autocomplete.addListener('place_changed', showPlaceInfo);

    function showPlaceInfo() {
      const place = autocomplete.getPlace();
      const placeName = document.getElementById("place_name");
      const placeAddress = document.getElementById("place_address");
      const placePhoto = document.getElementById("place_photo");

      emptyplaceInfoCard.style.display = "none"
      placeInfoCard.style.display = "block"
      placeName.textContent = place.name
      placeAddress.textContent = place.formatted_address
      placeId.value = place.place_id

      if(place.photos) {
        placePhoto.setAttribute('src', place.photos[0].getUrl())
      } else {
        placePhoto.setAttribute('src', "/assets/default_schedule_thumbnail.png")
      }
    }
  }
}

document.addEventListener('DOMContentLoaded', googlePlacesAutocomplete);
document.addEventListener('turbo:frame-load', googlePlacesAutocomplete);
