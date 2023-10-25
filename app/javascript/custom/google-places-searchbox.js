function initSearchBox() {
  if (!document.getElementById("map")) return;

  const map = new google.maps.Map(document.getElementById("map"), {
    center: { lat: 35.6814, lng: 139.7671 },
    zoom: 11,
  });
  const input = document.getElementById("searchbox_text_input");
  const searchBox = new google.maps.places.SearchBox(input);
  const userId = document.querySelector("#user_id")
  const itineraryId = document.querySelector("#itinerary_id")

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
        photo_url = "/assets/default_place.png"
      }

      if (itineraryId) {
        infowindow[i] =
          new google.maps.InfoWindow({
            content:
              `<div id="content" class="infowindow-content">
                <div class="row mx-0 p-1" id="bodyContent">
                  <div class="col-5 ps-0">
                    <img src=${photo_url} class="square-image">
                  </div>
                  <div class="col-7 px-0">
                    <p id="firstHeading" class="text-sm text-dark fw-bold lh-sm">${places[i].name}</p>
                    <p class="mb-2 text-xxs text-dark">
                      クチコミ評価<i class="material-icons rating-icon ps-1">star</i>${places[i].rating}
                    </p>
                    <a href="/itineraries/${itineraryId.value}/places/new?place_id=${places[i].place_id}" class="text-primary text-xs fw-bold" data-turbo-frame="modal">
                      スポット詳細<i class="material-icons fs-4" style="vertical-align: -7px;">navigate_next</i>
                    </a>
                  </div>
                </div>
              </div>`
          })
      } else {
        infowindow[i] =
        new google.maps.InfoWindow({
          content:
            `<div id="content" class="infowindow-content">
              <div class="row mx-0 p-1" id="bodyContent">
                <div class="col-5 ps-0">
                  <img src=${photo_url} class="square-image">
                </div>
                <div class="col-7 px-0">
                  <p id="firstHeading" class="text-sm text-dark fw-bold lh-sm">${places[i].name}</p>
                  <p class="mb-2 text-xxs text-dark">
                    クチコミ評価<i class="material-icons rating-icon ps-1">star</i>${places[i].rating}
                  </p>
                  <a href="/users/${userId.value}/places/new?place_id=${places[i].place_id}" class="text-primary text-xs fw-bold" data-turbo-frame="modal">
                    スポット詳細<i class="material-icons fs-4" style="vertical-align: -7px;">navigate_next</i>
                  </a>
                </div>
              </div>
            </div>`
        })
      }

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
document.addEventListener('turbo:load', initSearchBox);
