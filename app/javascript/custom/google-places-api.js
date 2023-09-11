
// const test = document.querySelector('#test');

// test.addEventListener('click', () => {

//   var service = new google.maps.places.PlacesService(map);
//   service.findPlaceFromQuery({
//     query: 'あ',
//     fields: ['name', 'formatted_address', 'geometry', 'place_id']
//   }, function(results, status) {
//     if (status == google.maps.places.PlacesServiceStatus.OK) {
//         // 配列となっていますが、1件しか返ってきません
//         for (var i = 0; i < results.length; i++) {
//             var place = results[i];
//             console.log(place.name);
//         }
//     }
// });
// })
{
  let autocomplete;

  function initAutocomplete() {
    const input = document.getElementById('query_input');
    const options = {
      fields: ["name", "formatted_address", "photos", "place_id", "geometry" ],
    };
    autocomplete = new google.maps.places.Autocomplete(input, options);
    autocomplete.addListener('place_changed', showPlaceInfo)
  }

  function showPlaceInfo() {
    const place = autocomplete.getPlace();
    const placeInfoCard = document.getElementById("place_info_card");
    const placeInfoEmpty = document.getElementById("place_info_empty");
    const placeName = document.getElementById("place_name")
    const placeAddress = document.getElementById("place_address")
    const placeImage = document.getElementById("place_image")

    placeInfoEmpty.style.display = "none"
    placeInfoCard.style.display = "block"
    placeName.textContent = place.name
    placeAddress.textContent = place.formatted_address

    if(place.photos) {
      placeImage.setAttribute('src', place.photos[0].getUrl())
    } else {
      placeImage.setAttribute('src', "/assets/default_schedule_thumbnail.png")
    }

    const resetPlaceBtn = document.getElementById("reset_place_btn")
    if(resetPlaceBtn) {
      resetPlaceBtn.addEventListener("click", () => {
        placeInfoEmpty.style.display = "block";
        placeInfoCard.style.display = "none";
      })
    }
  }

  document.addEventListener('turbo:frame-load', initAutocomplete);
}

