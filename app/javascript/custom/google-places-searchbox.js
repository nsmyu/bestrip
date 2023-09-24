function initSearchBox() {
  if (!document.getElementById("map")) return;

  const map = new google.maps.Map(document.getElementById("map"), {
    center: { lat: 35.6814, lng: 139.7671 },
    zoom: 11,
  });
  const input = document.getElementById("searchbox_text_input");
  const searchBox = new google.maps.places.SearchBox(input);

  map.addListener("bounds_changed", () => {
    searchBox.setBounds(map.getBounds());
  });

  let markers = [];
  let infowindow = [];

  searchBox.addListener("places_changed", () => {
    const places = searchBox.getPlaces();

    if (places.length == 0) return;

    markers.forEach((marker) => {
      marker.setMap(null);
    });
    markers = [];

    const bounds = new google.maps.LatLngBounds();

    for (let i = 0; i < places.length; i++) {
      if (!places[i].geometry || !places[i].geometry.location) {
        console.log("Returned place contains no geometry");
        return;
      }

      markers[i]= new google.maps.Marker({
        map,
        position: places[i].geometry.location,
      });

      let photo_url;
      if (places[i].photos) {
        photo_url = places[i].photos[0].getUrl()
      } else {
        photo_url = "/assets/default_schedule_thumbnail.png"
      }

      infowindow[i] =
        new google.maps.InfoWindow({
          content:
            `<div id="content" class="infowindow-content">
            <div id="siteNotice">
            </div>
            <div id="bodyContent">
            <img src=${photo_url} class="infowindow_place_photo">
            <div class="my-2">
            <p id="firstHeading" class="text-sm text-dark fw-bold lh-sm">${places[i].name}</p>
            <p class="text-xs text-dark fw-bold pt-1">
            <i class="material-icons rating-icon">star</i>${places[i].rating}
            </p>
            </div>
            <a href="/itineraries/${document.getElementById("itinerary_id").value}/favorites/new?place_id=${places[i].place_id}" class="btn btn-sm btn-outline-primary mb-0 w-100" data-turbo-frame="modal">情報を見る</a>
            </div>
            </div>`
        })

        "mouseover click".split(' ').forEach((eventType) => {
        markers[i].addListener(eventType, () => {
          for (const j in markers) {
            infowindow[j].close(map, markers[j]);
          }
          infowindow[i].open(map, markers[i])
        })
      })

      if (places[i].geometry.viewport) {
        bounds.union(places[i].geometry.viewport);
      } else {
        bounds.extend(places[i].geometry.location);
      }
    };
    map.fitBounds(bounds);
  });
}

document.addEventListener('DOMContentLoaded', initSearchBox);
