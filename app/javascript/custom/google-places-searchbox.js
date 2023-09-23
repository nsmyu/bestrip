function initSearchBox() {
  if (!document.getElementById("map")) return;

  const map = new google.maps.Map(document.getElementById("map"), {
    center: { lat: 35.6814, lng: 139.7671 },
    zoom: 10,
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

      infowindow[i] =
        new google.maps.InfoWindow({
          content:
            `<div id="content">
            <div id="siteNotice">
            </div>
            <h1 id="firstHeading" class="firstHeading">${places[i].name}</h1>
            <div id="bodyContent">
            <form enctype="multipart/form-data" action="/itineraries" accept-charset="UTF-8" method="post">
            <input type='submit'>
            </form>
            </div>
            </div>`
        })

      markers[i].addListener('mouseover', () => {
        for (const j in markers) {
          infowindow[j].close(map, markers[j]);
        }
        infowindow[i].open(map, markers[i])
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
