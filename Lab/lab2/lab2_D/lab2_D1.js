function initMap() {
  const map = new google.maps.Map(document.getElementById("map"), {
    zoom: 8,
    center: { lat: 44.9778, lng: -93.2650 },
    /* Full location: 44.977753, -93.2650108 */
  });
  const geocoder = new google.maps.Geocoder();
  const infowindow = new google.maps.InfoWindow();
  document.getElementById("submit").addEventListener("click", () => {
    geocodeAddress(geocoder, map, infowindow);
  });
}

function geocodeAddress(geocoder, resultsMap, infowindow) {
  const address = document.getElementById("address").value;
  geocoder.geocode({ address: address }, (results, status) => {
    if (status === "OK") {
      resultsMap.setCenter(results[0].geometry.location);
      const marker = new google.maps.Marker({
        map: resultsMap,
        position: results[0].geometry.location,
      });
      const contentString = 
        "<p>Address: " + results[0].formatted_address + "</p>" + 
        "<p>Marker Location: " + marker.getPosition() + "</p>";
      infowindow.setContent(contentString);
      infowindow.open(map, marker);
    } else {
      alert("Geocode was not successful for the following reason: " + status);
    }
  });
}